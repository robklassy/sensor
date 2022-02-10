class CreatePing < ActiveRecord::Migration[6.1]
  def change
    create_table :pings, id: :uuid do |t|
      t.datetime :transmitted_at
      t.datetime :acked_at
      t.integer :delay
      t.integer :expected_delay
      t.boolean :timeout
      
      t.timestamps
    end
  end
end
