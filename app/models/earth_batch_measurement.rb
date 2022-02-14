class EarthBatchMeasurement < ApplicationRecord
  has_many :earth_sensor_measurements
  has_many :earth_batch_measurement_data_files

  include FileHelper
  include GzipHelper

  state_machine :state, initial: :new do
    state :new
    state :processing
    state :finished
    state :errored

    event :start_processing do
      transition new: :processing
    end

    event :finish_processing do
      transition processing: :finished
    end

    event :error_out do
      transition all => :errored
    end
  end

  def process
    self.start_processing
    assemble_batch_sensor_measurement_gzip_and_gunzip
    find_or_create_sensor
    generate_sensor_measurements
    send_ack
    cleanup_temp_files([
      self.input_filenames,
      self.gzip_filename,
      self.sensor_measurement_json_filename
    ].flatten)
    self.finish_processing
  rescue => e
    cleanup_temp_files([self.gzip_filename, self.sensor_measurement_json_filename])
    self.error_out
    raise e
  end

  attr_accessor :input_filenames
  attr_accessor :gzip_filename
  attr_accessor :sensor_measurement_json_filename
  attr_accessor :sensor_measurement_hash

  private

  def assemble_batch_sensor_measurement_gzip_and_gunzip
    self.input_filenames = self.earth_batch_measurement_data_files.map(&:filename)
    # gunzip will fail with incomplete parts

    sort_hash = {}
    self.input_filenames.each do |fn|
      order_number = fn.split("split").last
      sort_hash[order_number] = fn
    end

    sorted_filenames = []
    sort_hash.keys.sort.each do |k|
      sorted_filenames << sort_hash[k]
    end

    self.gzip_filename = assemble_file_from_parts(sorted_filenames)
    self.sensor_measurement_json_filename = gunzip_files([self.gzip_filename]).first
    self.sensor_measurement_hash = JSON.parse(File.read(self.sensor_measurement_json_filename))
  end

  def find_or_create_sensor
    first_meas = self.sensor_measurement_hash[self.sensor_measurement_hash.keys.first]

    create_hash = {
      id: first_meas['sensor_id'],
      sensor_type: first_meas['type'],
      location: first_meas['location'],
      name: first_meas['name']
    }

    es = EarthSensor.where(id: create_hash[:id]).first
    if es.blank?
      es = EarthSensor.create(create_hash)
    end
    es
  end

  def generate_sensor_measurements
    self.sensor_measurement_hash.each_pair do |sm_id, meas_data|
      esm = self.earth_sensor_measurements.where(id: sm_id).first
      next if esm.present?

      create_hash = {
        id: sm_id,
      }
      create_hash.merge!(meas_data.slice(
        'data',
        'checksum_digest',
        'recorded_at'
      ))
      create_hash['earth_sensor_id'] = meas_data['sensor_id']

      self.earth_sensor_measurements.create(create_hash)
    end
  end

  def send_ack
    df_ids = self.earth_batch_measurement_data_files.pluck(:id)
    BatchMeasurementDataFile.where(id: df_ids).update_all(
      acked_at: Time.now.getutc
    )
  end

end