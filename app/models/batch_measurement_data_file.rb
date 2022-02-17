class BatchMeasurementDataFile < ApplicationRecord
  belongs_to :batch_measurement

  include FileHelper

  FILE_EXPORT_PATH = "/tmp/export"
  FILE_TRANSMISSION_PATH = "/tmp/transmitted"
  MAX_FILES_TO_TRANSMIT = 10
  MAX_FILES_TO_RETRY = 5

  def self.transmit_pending_files
    where('transmitted_at IS NULL')
      .where('filename IS NOT NULL')
      .order('created_at ASC')
      .limit(MAX_FILES_TO_TRANSMIT)
      .map(&:transmit)
  end

  # TODO - do time comparison in pg
  def self.retransmit_timed_out_files
    where('transmitted_at is NOT NULL')
      .where('acked_at is NULL')
      .order('transmitted_at ASC')
      .limit(MAX_FILES_TO_RETRY)
      .each do |rf|
        if Time.now.getutc.to_i > (rf.transmitted_at.to_i + rf.expected_delay)
          rf.transmit
        end
      end
  end

  # 'transmit' here just means copy it to the transmitted folder
  def transmit
    FileUtils.mkdir_p(BatchMeasurementDataFile::FILE_TRANSMISSION_PATH)

    if self.transmit_filename.blank?
      file = self.filename.split('/').last
      update_attribute(:transmit_filename, "#{BatchMeasurementDataFile::FILE_TRANSMISSION_PATH}/#{file}")
    end

    # this blocks it from actually retrying of course
    # return if File.exist?(transmit_filename)
    # disable to allow retries

    stdout, stderr, status =
      Open3
        .capture3("cp \"#{self.filename}\" \"#{self.transmit_filename}\"")

    if !status.success?
      raise stderr
    end

    update_attribute(:transmitted_at, Time.now.getutc)
    update_batch_measurement_transmitted_state
  rescue => e
    delete_transmission_file
    raise e
  end

  def delete_transmission_file
    cleanup_temp_files([self.transmit_filename])
  end

  def delete_exported_file
    cleanup_temp_files([self.filename])
  end

  def ack(time=nil)
    update_attribute(:acked_at, time || Time.now.getutc)
  end

  def update_batch_measurement_transmitted_state
    self.batch_measurement.update_transmitted_state
  end

  def update_batch_measurement_acked_state
    self.batch_measurement.update_acked_state
  end

  def destroy
    delete_exported_file
    delete_transmission_file
    super
  end
end