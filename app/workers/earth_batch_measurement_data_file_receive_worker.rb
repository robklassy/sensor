class EarthBatchMeasurementDataFileReceiveWorker
  include Sidekiq::Worker

  def perform
    EarthBatchMeasurementDataFile.receive_new_files
  end

end

Sidekiq::Cron::Job.create(name: 'EarthBatchMeasurementDataFileReceiveWorker', cron: '*/5 * * * *', class: 'EarthBatchMeasurementDataFileReceiveWorker')