class AddTransmitFilenameToBatchFile < ActiveRecord::Migration[6.1]
  def change
    add_column :batch_measurement_data_files, :transmit_filename, :string
  end
end
