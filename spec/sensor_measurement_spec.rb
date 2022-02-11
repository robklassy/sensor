# frozen_string_literal: true
require 'rails_helper'

describe SensorMeasurement do

  describe '#generate_hash' do
    let(:sensor) do
      Sensor::Temperature.create({
        name: 'Temp 1',
        location: 'dorsal'
      })
    end
    let(:sensor_measurement) { sensor.collect_data }

    it 'generates' do
      expect(sensor_measurement).to_not eq(nil)
      h = sensor_measurement.attributes.with_indifferent_access.slice(
        :id,
        :sensor_id,
        :data,
        :recorded_at,
        :checksum_digest,
      )

      h.merge!(type: sensor_measurement.sensor.type)
      expect(sensor_measurement.generate_hash).to eq(h)
    end

  end
end