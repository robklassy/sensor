class SensorCollectionWorker
  include Sidekiq::Worker

  def perform
    Sensor::Base.all.each do |s|
      s.collect_data
    end
  end
end

Sidekiq::Cron::Job.create(name: 'SensorCollectionWorker', cron: '*/1 * * * *', class: 'SensorCollectionWorker')