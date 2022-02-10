class Sensor::Base < ApplicationRecord
  self.abstract_class = true
  self.table_name = "sensors"
  
  has_many :sensor_measurements, class_name: 'SensorMeasurement', foreign_key: :sensor_id
end