class BatchMeasurement < ApplicationRecord
  has_many :sensor_measurements, class_name: 'SensorMeasurement', foreign_key: :batch_measurement_id

  after_create :generate_batch_data_files

  MAX_BATCH_MEASUREMENT_FILES_PER_SENSOR_TYPE = {
    'Sensor::Temperature' => 20,
  }.freeze


  def self.generate_next_batch_measurement

  end

  def generate_batch_measurement_files
  end

en