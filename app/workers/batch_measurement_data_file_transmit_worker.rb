class BatchMeasurementDataFileTransmitWorker
  include Sidekiq::Worker

  def perform
    BatchMeasurementDataFile.transmit_pending_files
  end
end

Sidekiq::Cron::Job.create(name: 'BatchMeasurementDataFileTransmitWorker', cron: '*/3 * * * *', class: 'BatchMeasurementDataFileTransmitWorker')