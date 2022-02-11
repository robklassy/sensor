class CreateEarthBatchMeasurementDataFile < ActiveRecord::Migration[6.1]
  def change
    create_table :earth_batch_measurement_data_files, id: :uuid do |t|
      t.uuid :earth_batch_measurement_id, foreign_key: true
      t.string :filename
      t.string :state
      t.datetime :received_at
      t.datetime :ack_sent_at

      t.timestamps
    end

    add_index :earth_batch_measurement_data_files, [:earth_batch_measurement_id], name: 'idx_ebmdf_earth_batch_measurement_id'
  end
end
