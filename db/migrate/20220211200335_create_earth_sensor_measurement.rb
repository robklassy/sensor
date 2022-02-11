class CreateEarthSensorMeasurement < ActiveRecord::Migration[6.1]
  def change
    create_table :earth_sensor_measurements, id: :uuid do |t|
      t.references :earth_batch_measurement, type: :uuid, index: true, foreign_key: true
      t.references :earth_sensor, type: :uuid, index: true, foreign_key: true
      t.jsonb :data
      t.string :data_checksum
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
