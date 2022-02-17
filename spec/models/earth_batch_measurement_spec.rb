require 'rails_helper'

describe EarthBatchMeasurement do
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
    EarthBatchMeasurementDataFile.receive_new_files
  end

  after(:each) do
    BatchMeasurement.cleanup_transmitted_batches
  end

  describe '#process' do
    it 'creates correct objects' do
      ebm = EarthBatchMeasurement.first
      #ebm.process
      expect(EarthSensor.count).to be > 0
      expect(EarthSensorMeasurement.count).to be > 0
    end
  end

end