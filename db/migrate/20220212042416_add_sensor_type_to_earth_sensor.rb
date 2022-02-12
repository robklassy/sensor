class AddSensorTypeToEarthSensor < ActiveRecord::Migration[6.1]
  def change
    add_column :earth_sensors, :sensor_type, :string
  end
end
