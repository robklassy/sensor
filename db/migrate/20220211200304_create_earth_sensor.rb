class CreateEarthSensor < ActiveRecord::Migration[6.1]
  def change
    create_table :earth_sensors, id: :uuid do |t|
      t.string :name
      t.string :location
      t.string :type

      t.timestamps
    end
  end
end
