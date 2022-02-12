class EarthSensorMeasurement < ApplicationRecord
  belongs_to :earth_batch_measurement
  belongs_to :earth_sensor
end