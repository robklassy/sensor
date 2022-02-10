class AddRecordedAtToSensorMeasurements < ActiveRecord::Migration[6.1]
  def change
    add_column :sensor_measurements, :recorded_at, :datetime, nil: false
  end
end
