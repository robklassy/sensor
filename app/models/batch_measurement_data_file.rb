class BatchMeasurementDataFile < ApplicationRecord
  belongs_to :batch_measurement

  MAX_NUMBER_OF_FILES_PER_SENSOR_TYPE = {
    'Sensor::Temperature' => 5
  }.freeze

  FILE_EXPORT_PATH = "/tmp/export"
  FILE_TRANSMISSION_PATH = "/tmp/transmitted"

end