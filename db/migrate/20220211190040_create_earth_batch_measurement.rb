class CreateEarthBatchMeasurement < ActiveRecord::Migration[6.1]
  def change
    create_table :earth_batch_measurements, id: :uuid do |t|
      t.string :state
      t.timestamps
    end
  end
end
