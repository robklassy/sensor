class PingWorker
  include Sidekiq::Worker

  PINGS_TO_GENERATE = 5

  def perform
    PINGS_TO_GENERATE.times do
      interval = rand(10..14)
      p = Ping.create
      PingResponseWorker.perform_in(interval.seconds, p.id)
      sleep(0.3)
    end

    Ping.timeout_pings
    Ping.delete_old_pings
  end

end

Sidekiq::Cron::Job.create(name: 'PingWorker', cron: '*/3 * * * *', class: 'PingWorker')