class EarthBatchMeasurement < ApplicationRecord
  has_many :earth_sensor_measurements
  has_many :earth_batch_measurement_data_files

  def process
  end

  private

  def assemble_batch_sensor_measurement_gzip_and_gunzip
  end

  def generate_sensor_measurements
  end

  def find_or_create_sensor
  end
end