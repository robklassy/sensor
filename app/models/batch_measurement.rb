class BatchMeasurement < ApplicationRecord
  has_many :sensor_measurements, class_name: 'SensorMeasurement', foreign_key: :batch_measurement_id
  has_many :batch_measurement_data_files

  include FileHelper
  include GzipHelper

  state_machine :state, initial: :new do
    state :new
    state :generating_files
    state :ready_to_transmit
    state :files_transmitting
    state :files_transmitted
    state :all_files_acked
    state :errored

    event :generate_files do
      transition new: :generating_files
    end

    event :finish_generate_files do
      transition generating_files: :ready_to_transmit
    end

    event :transmit_files do
      transition ready_to_transmit: :files_transmitting
    end

    event :finish_transmit_files do
      transition files_transmitting: :files_transmitted
    end

    event :ack_all_files do
      transition files_transmitted: :all_files_acked
    end

    event :error_out do
      transition all => :errored
    end
  end

  MAX_BATCH_MEASUREMENT_FILES_PER_SENSOR_TYPE = {
    'Sensor::Temperature' => 20,
  }.freeze

  attr_accessor :filename
  attr_accessor :gzip_filename
  attr_accessor :split_filenames

  def self.generate_next_batch_measurement
    MAX_BATCH_MEASUREMENT_FILES_PER_SENSOR_TYPE.each_pair do |klass_string, limit|
      count = SensorMeasurement.joins(:sensor)
        .where(batch_measurement_id: nil)
        .where('"sensors"."type" = ?', klass_string)
        .count(1)

      if count > 0
          bm = BatchMeasurement.create
          bm.generate_files

          SensorMeasurement.joins(:sensor)
            .where(batch_measurement_id: nil)
            .where('"sensors"."type" = ?', klass_string)
            .order('"sensor_measurements"."recorded_at" ASC')
            .limit(limit).each do |sm|
              sm.update_attribute(:batch_measurement_id, bm.id)
            end
          bm.generate_batch_measurement_data_files
          bm.finish_generate_files
      end
    end
  end

  def self.cleanup_transmitted_batches
    where(state: 'all_files_acked').each do |bm|
      bm.batch_measurement_data_files.map(&:destroy)
    end
  end

  def generate_batch_measurement_data_files
    file_string_hash = {}
    sensor_type = self.sensor_measurements.first.sensor.type
    sensor_measurements.each do |sm|
      file_string_hash[sm.id] = sm.generate_hash
    end

    # generate a batch JSON and write to file
    unix_time = Time.now.getutc.to_i
    FileUtils.mkdir_p(BatchMeasurementDataFile::FILE_EXPORT_PATH)
    self.filename = "#{BatchMeasurementDataFile::FILE_EXPORT_PATH}/#{unix_time}--#{sensor_type}--#{self.id}.json"
    f = File.open(self.filename, 'w') do |file|
      file.write(file_string_hash.to_json)
    end

    # zip the file and split the file into 1kb pieces
    self.gzip_filename = gzip_file(self.filename)
    self.split_filenames = split_file_into_parts(self.gzip_filename)

    # create the data files
    self.split_filenames.each do |sf|
      bmdf = self.batch_measurement_data_files.new(
        data_type: 'data',
        expected_delay: Ping.average_delay
      )
      bmdf.save!

      base_fn = sf.split('.json.gz').first
      split_suffix = sf.split('.json.gz').last
      new_split_filename = "#{base_fn}---#{bmdf.id}.json.gz#{split_suffix}"

      stdout, stderr, status =
        Open3
          .capture3("mv \"#{sf}\" \"#{new_split_filename}\"")

      if !status.success?
        raise stderr
      end

      bmdf.update_attribute(:filename, new_split_filename)
    end

    cleanup_temp_files([self.filename, self.gzip_filename])
  rescue => e
    cleanup_temp_files([self.filename, self.gzip_filename, self.split_filenames])
    raise e
  end

  def update_transmitted_state
    if self.batch_measurement_data_files.where('transmitted_at IS NOT NULL').count ==
      self.batch_measurement_data_files.count
        self.finish_transmit_files
    end
  end

  def update_acked_state
    if self.batch_measurement_data_files.where('transmitted_at IS NOT NULL AND acked_at IS NOT NULL').count ==
      self.batch_measurement_data_files.count
        self.ack_all_files
    end
  end

end