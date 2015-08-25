module LegoEv3
  class TouchSensor < LegoSensor
    def initialize(connection, id, port)
      super(connection, id, port, 'lego-ev3-touch')
    end

    def pressed?
      @value == 1
    end

    def poll
      @value = LegoEv3::Commands::LegoSensor.get_value0!(@connection, @id)
    end

    def info
      super.merge({
        sub_type: :touch,
        pressed: pressed?
      })
    end
  end
end
