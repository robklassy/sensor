require 'rails_helper'

describe Ping do

  describe '#ping' do
    context 'not acked' do
      let!(:pings) do
        25.times do
          Ping.create
          sleep(0.1)
        end
      end

      it 'sets transmitted_at' do
        transmitted_ats = Ping.all.map(&:transmitted_at)
        expect(transmitted_ats.compact.count).to be > 0
        expect(transmitted_ats.compact.count).to eq(transmitted_ats.count)
      end
    end

    context 'acked' do
      let!(:acked_pings) do
        25.times do
          p = Ping.create
          p.ack(Time.now.getutc + rand(12..17).seconds)
          sleep(0.1)
        end
      end

      it 'sets acked_at and calculates delay and calculates expected_delay' do
        acked_ats = Ping.all.map(&:acked_at)
        delays = Ping.all.map(&:delay)
        expected_delays = Ping.order('created_at ASC').map(&:expected_delay)

        expect(acked_ats.compact.count).to be > 0
        expect(acked_ats.compact.count).to eq(acked_ats.count)

        expect(delays.compact.count).to be > 0
        delays_present = delays.map { |d| d.present? }
        expect(delays_present.first).to eq(true)
        expect(delays_present.uniq).to eq([true])

        expect(expected_delays.compact.count).to be > 0
        expect(expected_delays.first).to eq(0)
        expected_delays_present = expected_delays.map { |d| d.present? }
        expect(expected_delays_present.first).to eq(true)
        expect(expected_delays_present.uniq).to eq([true])
      end
    end
  end

  describe ".average_delay" do
    let!(:acked_pings) do
      10.times do
        p = Ping.create
        p.ack(Time.now.getutc + rand(12..17).seconds)
        sleep(0.1)
      end
    end

    it 'calculates average delay' do
      expect(Ping.average_delay).to be_between(12, 17)
    end
  end

  describe ".latest_delay" do
    let!(:acked_pings) do
      3.times do
        p = Ping.create
        p.ack(Time.now.getutc + rand(12..17).seconds)
        sleep(1)
      end
    end

    it 'returns latest delay' do
      latest = Ping.where('acked_at IS NOT NULL').order('acked_at DESC').first.try(:delay)
      expect(Ping.latest_delay).to eq(latest)
    end
  end
end

