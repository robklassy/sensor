
class CreateReceivedCommand < ActiveRecord::Migration[6.1]
  def change
    create_table :received_commands, id: :uuid do |t|
      t.datetime :received_at
      t.datetime :remote_transmitted_at
      t.integer :delay
      t.string :received_command_type
      t.jsonb :data

      t.timestamps
    end
  end
end
