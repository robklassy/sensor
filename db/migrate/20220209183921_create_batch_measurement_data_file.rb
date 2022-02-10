class CreateBatchMeasurementDataFile < ActiveRecord::Migration[6.1]
  def change
    create_table :batch_measurement_data_files, id: :uuid do |t|
      t.references :batch_measurement, type: :uuid, index: true, foreign_key: true
      t.string :data_type
      t.string :filename
      t.string :state
      t.datetime :transmitted_at
      t.datetime :acked_at
      t.integer :expected_delay

      t.timestamps
    end
  end
end
