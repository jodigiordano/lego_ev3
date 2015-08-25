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

      @modes_value_parts = {
        reflect: 1,
        ambient: 1,
        color: 1,
        reflect_raw: 2,
        rgb: 3
      }

      @value_to_color = [:none, :black, :blue, :green, :yellow, :red, :white, :brown]

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
      @value = parse_value(poll_value(@modes_value_parts[@mode]))
    end

    def info
      super.merge({
        sub_type: :color,
        mode: @mode,
        value: @value
      })
    end

    private

    def parse_mode(raw)
      @supported_modes.select do |key, value|
        raw == value
      end.first[0]
    end

    def parse_value(raw)
      if @mode == :reflect || @mode == :ambient
        raw.first.to_f / 100 # percent
      elsif @mode == :color
        @value_to_color[raw.first]
      elsif @mode == :reflect_raw
        raw[0..1]
      elsif @mode == :rgb
        raw[0..2]
      end
    end
  end
end
