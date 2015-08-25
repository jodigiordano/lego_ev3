module LegoEv3
  class ColorSensor < LegoSensor
    def initialize(connection, id, port)
      super(connection, id, port, 'lego-ev3-color')

      @supported_modes = {
        reflect: 'COL-REFLECT',
        ambient: 'COL-AMBIENT',
        color: 'COL-COLOR',
        reflect_raw: 'REF-RAW',
        rgb: 'RGB-RAW'
      }

      self.mode = :reflect
    end

    def mode
      @mode = parse_mode(LegoEv3::Commands::LegoSensor.get_mode!(@connection, @id))
    end

    def mode=(new_value)
      to_set = @supported_modes[new_value.to_sym]
      throw new InvalidModeException(:sensor, :color, new_value, @supported_modes.keys) unless to_set

      LegoEv3::Commands::LegoSensor.set_mode(@connection, @id, to_set)
      LegoEv3::Commands::LegoSensor.get_mode(@connection, @id) do |m|
        @mode = parse_mode(m)
      end

      @connection.flush
      @mode
    end

    def poll
      @value = LegoEv3::Commands::LegoSensor.get_value0!(@connection, @id)
    end

    def info
      super.merge({
        sub_type: :color,
        mode: @mode
      })
    end

    private

    def parse_mode(raw)
      @supported_modes.select do |key, value|
        raw == value
      end.first[0]
    end
  end
end
