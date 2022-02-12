require 'rails_helper'

describe EarthBatchMeasurementDataFile do
  let!(:sensor) do
    s = Sensor::Temperature.new(
      name: 'Temp 1',
      location: 'dorsal'
    )
    s.save!
    s
  end
  let!(:sensor_measurement) { 25.times { sleep(0.07); sensor.collect_data }}

  before(:each) do
    BatchMeasurement.generate_next_batch_measurement
    BatchMeasurementDataFile.transmit_pending_files
  end

  describe '.receive_new_files' do
    it 'creates correct objects' do
      EarthBatchMeasurementDataFile.receive_new_files
      expect(BatchMeasurement.pluck(:id) & EarthBatchMeasurement.pluck(:id)).to_not be(nil)
      expect(BatchMeasurementDataFile.pluck(:id) & EarthBatchMeasurementDataFile.pluck(:id)).to_not be(nil)
    end
  end

end