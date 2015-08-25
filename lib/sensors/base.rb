module LegoEv3
  # More info: http://www.ev3dev.org/docs/drivers/lego-sensor-class/
  class LegoSensor
    def initialize(connection, id, port, driver_name)
      @connection = connection
      @id = id
      @port = port
      @driver_name = driver_name
    end

    def info
      {
        id: @id,
        port: @port,
        driver_name: @driver_name
      }
    end

    protected
    
    def poll_value(parts_count)
      raw = []

      parts_count.times do |i|
        LegoEv3::Commands::LegoSensor.send("get_value#{i}", @connection, @id) do |value|
          raw << value
        end
      end

      @connection.flush

      raw
    end
  end
end
