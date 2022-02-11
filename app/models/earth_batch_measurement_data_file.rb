class EarthBatchMeasurementDataFile < ApplicationRecord
  belongs_to :earth_batch_measurement

  def send_ack
    #launch transmit command worker here
  end

end