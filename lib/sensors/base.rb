module LegoEv3
  # More info: http://www.ev3dev.org/docs/drivers/lego-sensor-class/
  class LegoSensor
    def initialize(connection, id, port, driver_name)
      @connection = connection
      @id = id
      @port = port
      @driver_name = driver_name

      LegoEv3::Commands::LegoSensor.get_decimals(@connection, @id) do |response|
        @decimals = response
      end

      LegoEv3::Commands::LegoSensor.get_num_values(@connection, @id) do |response|
        @value_parts_count = response
      end

      @connection.flush
    end

    def info
      {
        id: @id,
        port: @port,
        driver_name: @driver_name,
        decimals: @decimals
      }
    end
  end
end
