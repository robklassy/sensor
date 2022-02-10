class SensorMeasurement < ApplicationRecord
  belongs_to :sensor, class_name: 'Sensor::Base'

  def delete
  end

  def generate_hash
    self.attributes.with_indifferent_access.slice(
      :id,
      :sensor_id,
      :data,
      :recorded_at,
      :checksum_digest,
    )
  end
end