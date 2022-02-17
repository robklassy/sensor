class BatchMeasurementGenerationWorker
  include Sidekiq::Worker

  def perform
    BatchMeasurement.generate_next_batch_measurement
    BatchMeasurement.cleanup_transmitted_batches
  end
end

Sidekiq::Cron::Job.create(name: 'BatchMeasurementGenerationWorker', cron: '*/1 * * * *', class: 'BatchMeasurementGenerationWorker')