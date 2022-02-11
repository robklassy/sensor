class Ping < ApplicationRecord

  after_create :ping

  def self.comm_blackout?
  end

  def self.timeout_pings
  end

  def self.delete_old_pings
  end

  def self.latest_delay
    where('acked_at IS NOT NULL').order('acked_at DESC').first.try(:delay)
  end

  def self.average_delay
    delays = where('delay IS NOT NULL').order('acked_at DESC').limit(20).pluck(:delay)
    return 0 if delays.empty?
    delays.compact.sum / delays.size
  end

  def ping
    return if transmitted_at.present?
    expected_delay = Ping.average_delay
    update(
      transmitted_at: Time.now.getutc,
      expected_delay: expected_delay
    )
  end

  def ack(time=nil)
    time = time || Time.now.getutc
    update(
      acked_at: time,
      delay: time.to_i - transmitted_at.to_i
    )
  end

end