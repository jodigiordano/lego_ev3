module LegoEv3
  class InfraredSensor < LegoSensor
    def initialize(connection, id, port)
      super(connection, id, port, 'lego-ev3-ir')
    end

    def poll
      
    end

    def info
      super.merge({
        sub_type: :infrared
      })
    end
  end
end
