# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_02_10_211857) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "batch_measurement_data_files", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "batch_measurement_id"
    t.string "data_type"
    t.string "filename"
    t.string "state"
    t.datetime "transmitted_at"
    t.datetime "acked_at"
    t.integer "expected_delay"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["batch_measurement_id"], name: "index_batch_measurement_data_files_on_batch_measurement_id"
  end

  create_table "batch_measurements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "state"
    t.text "file_string"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "transmitted_at"
    t.datetime "acked_at"
    t.integer "delay"
    t.integer "expected_delay"
    t.boolean "timeout"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "received_commands", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "received_at"
    t.datetime "remote_transmitted_at"
    t.integer "delay"
    t.string "received_command_type"
    t.jsonb "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sensor_measurements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sensor_id"
    t.uuid "batch_measurement_id"
    t.jsonb "data", default: {}
    t.string "checksum_digest"
    t.boolean "received", default: false
    t.boolean "ready_to_delete", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "recorded_at"
    t.index ["batch_measurement_id"], name: "index_sensor_measurements_on_batch_measurement_id"
    t.index ["sensor_id"], name: "index_sensor_measurements_on_sensor_id"
  end

  create_table "sensors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.string "type"
    t.string "state"
    t.datetime "last_collected_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "batch_measurement_data_files", "batch_measurements"
  add_foreign_key "sensor_measurements", "batch_measurements"
  add_foreign_key "sensor_measurements", "sensors"
end
