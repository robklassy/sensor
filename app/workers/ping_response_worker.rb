class PingResponseWorker
  include Sidekiq::Worker

  def perform(ping_id)
    p = Ping.find(ping_id)
    p.ack(Time.now.getutc)
  end
end