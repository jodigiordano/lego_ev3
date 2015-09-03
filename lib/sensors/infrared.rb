module LegoEv3
  # More info: http://www.ev3dev.org/docs/sensors/lego-ev3-infrared-sensor/
  # TODO: make sense of proximity
  class InfraredSensor < LegoSensor
    def initialize(connection, id, port)
      super(connection, id, port, 'lego-ev3-ir')

      @supported_modes = {
        proximity: 'IR-PROX',
        seek: 'IR-SEEK',
        control: 'IR-REMOTE',
        control_alt: 'IR-REM-A'
      }

      @modes_value_parts = {
        proximity: 1,
        seek: 8,
        control: 4,
        control_alt: 1
      }

      @control_pressed_buttons = [
        [],
        [:red_up],
        [:red_down],
        [:blue_up],
        [:blue_down],
        [:red_up, :blue_up],
        [:red_up, :blue_down],
        [:red_down, :blue_up],
        [:red_down, :blue_down],
        [:beacon_on],
        [:red_up, :red_down],
        [:blue_up, :blue_down]
      ]

      self.mode = :proximity

      @channel = 1

      init_values
    end

    def channel
      @channel
    end

    def channel=(new_value)
      @channel = [1, new_value.to_i, 4].sort[1]

      init_values
    end

    def mode
      @mode = parse_mode(LegoEv3::Commands::LegoSensor.get_mode!(@connection, @id))
    end

    def mode=(new_value)
      to_set = @supported_modes[new_value.to_sym]
      throw new InvalidModeException(:sensor, :infrared, new_value, @supported_modes.keys) unless to_set

      LegoEv3::Commands::LegoSensor.set_mode(@connection, @id, to_set)
      LegoEv3::Commands::LegoSensor.get_mode(@connection, @id) do |m|
        @mode = parse_mode(m)
      end

      @connection.flush

      init_values

      @mode
    end

    def poll
      throw new InvalidChannelException(@channel) if @mode == :control_alt && @channel != 1
      @last_value_raw = @value_raw
      @value_raw = poll_value(@modes_value_parts[@mode])
      @value = parse_value(@value_raw)
    end

    def info
      super.merge({
        sub_type: :infrared,
        mode: @mode,
        value: @value,
        channel: @channel
      })
    end

    private

    # TODO Eventually use this to solve the "value 262" problem.
    def init_values
      @value = nil
      @value_raw = nil
      @last_value_raw = nil
    end

    def parse_mode(raw)
      @supported_modes.select do |key, value|
        raw == value
      end.first[0]
    end

    def parse_value(raw)
      if @mode == :proximity
        raw.first.to_f / 100 # percent, [0, 1]. 100% is approximately 70cm.
      elsif @mode == :seek
        bit_position = (@channel - 1) * 4
        values_at_position = raw[bit_position, bit_position + 1]

        # When looking in the same direction as the sensor,
        # -25 is far left and +25 is far right.
        {
          heading: values_at_position[0].to_f / 25, # percent, [-1, 1]
          distance: values_at_position[1].to_f / 100, # percent, [0, 1]
          activated: values_at_position[1] != -128
        }
      elsif @mode == :control
        bit_position = @channel - 1
        value_at_position = raw[bit_position]
        @control_pressed_buttons[value_at_position]
      elsif @mode == :control_alt
        value = []

        # TODO: Pressing an up/down button while beacon mode
        # TODO: is activated with turn off beacon mode.

        # TODO: Also, when the beacon mode is active or for
        # TODO: about 1 second after any button is released the value is 262.
        if raw[0] & 0x0F > 0
          value << :blue_down if raw[0][7] == 1
          value << :blue_up if raw[0][6] == 1
          value << :red_down if raw[0][5] == 1
          value << :red_up if raw[0][4] == 1
        end

        value
      end
    end
  end
end
