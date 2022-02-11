class BatchMeasurementGenerationWorker
  include Sidekiq::Worker

  def perform
    BatchMeasurement.generate_next_batch_measurement
  end
end

Sidekiq::Cron::Job.create(name: 'BatchMeasurementGenerationWorker', cron: '*/5 * * * *', class: 'BatchMeasurementGenerationWorker')