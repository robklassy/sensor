# frozen_string_literal: true
require 'rails_helper'

describe Sensor::Temperature do

  describe '#fahrenheit_to_celsius' do
    let(:temp_f) { 45 }
    let(:sensor) { Sensor::Temperature.new }

    it 'converts correctly' do
      expect(sensor.send(:fahrenheit_to_celsius, temp_f).round(2)).to eq(7.22)
    end
  end

  describe '#collect_data' do
    let(:sensor) do
      Sensor::Temperature.create({
        name: 'Temp 1',
        location: 'dorsal'
      })
    end
    let(:sensor_measurement) { sensor.collect_data }
    let(:sensor_measurement2) { sensor.collect_data }

    it 'creates a SensorMeasurement' do
      expect(sensor_measurement).to_not eq(nil)
      expect(sensor_measurement.class).to eq(SensorMeasurement)
    end

    it 'sets delta' do
      expect(sensor_measurement).to_not eq(nil)
      expect(sensor_measurement2).to_not eq(nil)

      delta = sensor_measurement2.data['temperature'].to_f - sensor_measurement.data['temperature'].to_f
      expect(sensor_measurement2.data['delta']).to eq(delta)
    end

  end

end