class CreateBatchMeasurement < ActiveRecord::Migration[6.1]
  def change
    create_table :batch_measurements, id: :uuid do |t|
      t.string :state
      t.text :file_string

      t.timestamps
    end
  end
end
