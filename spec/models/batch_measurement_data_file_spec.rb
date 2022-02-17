# frozen_string_literal: true
require 'rails_helper'

describe BatchMeasurementDataFile do
  let!(:sensor) do
    s = Sensor::Temperature.new(
      name: 'Temp 1',
      location: 'dorsal'
    )
    s.save!
    s
  end

  let!(:acked_pings) do
    25.times do
      p = Ping.create
      p.ack(Time.now.getutc + rand(12..17).seconds)
      sleep(0.1)
    end
  end

  let!(:sensor_measurement) do
    25.times { sleep(0.07); sensor.collect_data }
  end

  before(:each) do
    BatchMeasurement.generate_next_batch_measurement
  end

  after(:each) do
    BatchMeasurement.cleanup_transmitted_batches
  end

  describe '#transmit' do
    context 'file does not exist' do
      it 'copies file to transmit dir' do
        expect(BatchMeasurementDataFile.count).to be > 0
        bmdf = BatchMeasurementDataFile.first
        expect(bmdf.filename).to_not be(nil)
        bmdf.transmit
        expect(bmdf.transmit_filename).to_not be(nil)
        expect(File.exist?(bmdf.filename)).to eq(true)
        BatchMeasurementDataFile.all.map(&:delete_transmission_file)
        BatchMeasurementDataFile.all.map(&:delete_exported_file)
      end
    end

    context 'file exists (idempotent)' do
      it 'is the same file' do
        expect(BatchMeasurementDataFile.count).to be > 0
        bmdf = BatchMeasurementDataFile.first
        expect(bmdf.filename).to_not be(nil)
        bmdf.transmit
        transmit_filename = bmdf.transmit_filename
        expect(transmit_filename).to_not be(nil)
        expect(File.exist?(transmit_filename)).to eq(true)
        bmdf.transmit
        expect(bmdf.reload.transmit_filename).to eq(transmit_filename)
        expect(File.exist?(transmit_filename)).to eq(true)
        BatchMeasurementDataFile.all.map(&:delete_transmission_file)
        BatchMeasurementDataFile.all.map(&:delete_exported_file)
      end
    end
  end

  describe '.transmit_pending_files' do
    it 'transmits pending files' do
      transmitted_ats = BatchMeasurementDataFile.all.map(&:transmitted_at)
      expect(transmitted_ats.compact.count).to eq(0)
      BatchMeasurementDataFile.transmit_pending_files
      expect(BatchMeasurementDataFile.where('transmitted_at IS NOT NULL')
        .count(1)).to be_between(1, BatchMeasurementDataFile::MAX_FILES_TO_TRANSMIT)
      BatchMeasurementDataFile.all.map(&:delete_transmission_file)
      BatchMeasurementDataFile.all.map(&:delete_exported_file)
    end
  end

  describe '.retransmit_timed_out_files' do
    it 'retransmits timed out files' do
      transmitted_ats = BatchMeasurementDataFile.all.map(&:transmitted_at)
      expect(transmitted_ats.compact.count).to eq(0)
      BatchMeasurementDataFile.transmit_pending_files
      expect(BatchMeasurementDataFile.where('transmitted_at IS NOT NULL')
        .count(1)).to be_between(1, BatchMeasurementDataFile::MAX_FILES_TO_TRANSMIT)

      before_transmitted_ats = BatchMeasurementDataFile.all.map(&:transmitted_at)
      BatchMeasurementDataFile.where('transmitted_at IS NOT NULL').update_all(expected_delay: 2)

      sleep(3)
      BatchMeasurementDataFile.retransmit_timed_out_files
      after_transmitted_ats = BatchMeasurementDataFile.all.map(&:transmitted_at)

      expect(after_transmitted_ats.map(&:to_i).sort.first - before_transmitted_ats.map(&:to_i).sort.first).to be >= 3

      BatchMeasurementDataFile.all.map(&:delete_transmission_file)
      BatchMeasurementDataFile.all.map(&:delete_exported_file)
    end
  end
end