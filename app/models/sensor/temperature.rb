class Sensor::Temperature < Sensor::Base
  self.table_name = "sensors"



  validates :name, presence: true
  validates :location, presence: true

  def initialize(options={})
    super(options)
  end

  def collect_data
    temperature = fahrenheit_to_celsius(generate_temperature_f)
    timestamp = Time.now.getutc

    previous_temp_data = sensor_measurements
      .order('recorded_at DESC')
      .first.try(:data)

    delta = if previous_temp_data
              temperature.to_f - previous_temp_data['temperature'].to_f
            else
              nil
            end

    data_hash = { temperature: temperature, timestamp: timestamp, delta: delta }

    sm = sensor_measurements.new({
      data: data_hash,
      checksum_digest: generate_checksum_digest(data_hash.to_s),
      recorded_at: timestamp
    })
    sm.save!
    sm
  end

  private

  def fahrenheit_to_celsius(temp_f)
    (temp_f.to_f - 32.0) * 5.0 / 9.0
  end

  def generate_temperature_f
    rand((-10000.00)..(10000.00)).round(3)
  end

  def generate_checksum_digest(string)
    Digest::SHA256.hexdigest(string)
  end

end