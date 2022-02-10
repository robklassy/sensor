class CreateSensorMeasurement < ActiveRecord::Migration[6.1]
  def change
    create_table :sensor_measurements, id: :uuid do |t|
      t.references :sensor, type: :uuid, index: true, foreign_key: true
      t.references :batch_measurement, type: :uuid, index: true, foreign_key: true, nil: true
      t.jsonb :data, default: {}
      t.string :checksum_digest
      t.boolean :received, default: false
      t.boolean :ready_to_delete, default: false

      t.timestamps
    end
  end
end
