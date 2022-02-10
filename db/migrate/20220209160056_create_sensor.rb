class CreateSensor < ActiveRecord::Migration[6.1]
  def change
    create_table :sensors, id: :uuid do |t|
      t.string :name
      t.string :location
      t.string :type
      t.string :state
      t.datetime :last_collected_at
      t.timestamps
    end
  end
end
