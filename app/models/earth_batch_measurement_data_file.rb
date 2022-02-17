class EarthBatchMeasurementDataFile < ApplicationRecord
  belongs_to :earth_batch_measurement

  extend FileHelper

  def self.receive_new_files
    bm_regex = /--[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/i
    bmdf_regex = /---[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/i

    files_to_receive = Dir.entries(BatchMeasurementDataFile::FILE_TRANSMISSION_PATH)
    files_to_receive = files_to_receive
      .map { |rf| "#{BatchMeasurementDataFile::FILE_TRANSMISSION_PATH}/#{rf}" }
      .select { |rf| rf =~ bm_regex }
      .reject { |rf| rf !~ /split/i }

    ebm = nil
    files_to_receive.each do |rf|
      next if rf !~ bm_regex

      bm_id = rf.scan(bm_regex).first.gsub('--', '')
      bmdf_id = rf.scan(bmdf_regex).first.gsub('---', '')

      ebm = EarthBatchMeasurement.where(id: bm_id).first
      if ebm.blank?
        ebm = EarthBatchMeasurement.new(
          id: bm_id
        )
        ebm.save!
      end

      ebmdf = ebm.earth_batch_measurement_data_files.where(id: bmdf_id).first
      if ebmdf.blank?
        ebmdf = EarthBatchMeasurementDataFile.new(
          id: bmdf_id,
          earth_batch_measurement_id: ebm.id,
          filename: rf,
          received_at: Time.now.getutc
        )
        ebmdf.save!
      end
    end

    ebm.try(:process)
  end

  def send_ack
    #launch transmit command worker here
  end
end