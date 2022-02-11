# frozen_string_literal: true
require 'rails_helper'

describe BatchMeasurement do

  describe '.generate_next_batch_measurement' do
    let!(:sensor) do
      s = Sensor::Temperature.new(
        name: 'Temp 1',
        location: 'dorsal'
      )
      s.save!
      s
    end
    let!(:sensor_measurement) { 25.times { sleep(0.07); sensor.collect_data }}

    it 'generates BatchMeasurementDataFiles' do
      expect(SensorMeasurement.count).to eq(25)
      BatchMeasurement.generate_next_batch_measurement
      expect(BatchMeasurement.count).to be > 0
      expect(SensorMeasurement.where('batch_measurement_id IS NOT NULL').count(1)).to eq(20)
      expect(BatchMeasurementDataFile.count).to be > 0
    end

  end
end