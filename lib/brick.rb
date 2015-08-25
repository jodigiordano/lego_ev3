module LegoEv3
  class Brick
    def initialize(connection)
      @connection = connection
      @ports = []
      @devices = []
      @motors = []
      @sensors = []

      refresh!
      motors.each{ |m| m.reset }
    end

    def motors
      @motors
    end

    def sensors
      @sensors
    end

    def refresh!
      @ports = LegoEv3::Commands::LegoPort.list!(@connection).map do |port|
        { id: port }
      end

      # Retrieve name and status in batch.
      @ports.each do |port|
        LegoEv3::Commands::LegoPort.get_port_name(@connection, port[:id]) do |name|
          port[:name] = name
        end

        LegoEv3::Commands::LegoPort.get_status(@connection, port[:id]) do |status|
          port[:status] = status
        end
      end

      @connection.flush("Refreshed ports and their status")

      # Retrieve Port name -> Tacho motor in batch.
      tacho_motors = {}
      LegoEv3::Commands::TachoMotor.list!(@connection).each do |motor|
        LegoEv3::Commands::TachoMotor.get_port_name(@connection, motor) do |port_name|
          tacho_motors[port_name] = motor
        end
      end

      # Retrieve Port name -> Lego sensor in batch.
      lego_sensors = {}
      LegoEv3::Commands::LegoSensor.list!(@connection).each do |sensor|
        LegoEv3::Commands::LegoSensor.get_port_name(@connection, sensor) do |port_name|
          lego_sensors[port_name] = sensor
        end
      end

      @connection.flush("Refreshed motors and sensors")

      # Assemble port info.
      @ports.each do |port|
        status = port.delete(:status)
        connected =
          status != 'no-sensor' &&
          status != 'no-motor' &&
          status != 'error'

        port[:type] = port[:name].start_with?('in') ? :sensor : :motor
        port[:connected] = connected
        port[:error] = status == 'error'
        port[:driver] = connected ? status : nil
      end

      @motors = @ports
        .select{ |p| p[:type] == :motor && p[:connected] }
        .map{ |p| LegoEv3::TachoMotor.new(@connection, tacho_motors[p[:name]], p) }

      @sensors = @ports
        .select{ |p| p[:type] == :sensor && p[:connected] }
        .map do |p|
          id = lego_sensors[p[:name]]
          driver_name = LegoEv3::Commands::LegoSensor.get_driver_name!(@connection, id)

          if driver_name == 'lego-ev3-touch'
            LegoEv3::TouchSensor.new(@connection, id, p)
          else
            nil
          end
        end.compact
    end

    def info
      {
        ports: @ports,
        motors: @motors.map(&:info),
        sensors: @sensors.map(&:info)
      }
    end
  end
end
