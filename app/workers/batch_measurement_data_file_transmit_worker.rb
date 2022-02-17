class BatchMeasurementDataFileTransmitWorker
  include Sidekiq::Worker

  def perform
    BatchMeasurementDataFile.transmit_pending_files
    BatchMeasurementDataFile.retransmit_timed_out_files
  end
end

Sidekiq::Cron::Job.create(name: 'BatchMeasurementDataFileTransmitWorker', cron: '*/1 * * * *', class: 'BatchMeasurementDataFileTransmitWorker')