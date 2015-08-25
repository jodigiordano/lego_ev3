module LegoEv3
  # More info: http://www.ev3dev.org/docs/drivers/tacho-motor-class/
  # TODO: ramp_up_sp, ramp_down_sp
  # TODO: handle 'run_direct' and 'run_forever' states
  # TODO: speed_regulation by default?
  class TachoMotor
    def initialize(connection, id, port)
      @connection = connection
      @id = id
      @port = port

      @speed = 0
      @desired_speed = 0
      @ticks_per_rotation = 0
      @polarity = :normal
      @position = 0
      @desired_position = 0
      @desired_time_ms = 0
      @stop_mode = :coast
      @running = false
      @ramping = false
      @holding = false
      @stalled = false
      @regulated_speed = false

      sync!
    end

    # Run the motor indefinitely, until another command is sent.
    def run_forever
      ensure_valid_speed

      LegoEv3::Commands::TachoMotor.run_forever!(@connection, @id)
    end

    # Run to an absolute position specified by *desired_position*.
    # Then stop using the current stop behavior.
    def run_to_absolute_position(desired_position)
      ensure_valid_speed
      old_position = position

      LegoEv3::Commands::TachoMotor.set_position_sp!(@connection, @id, desired_position)
      LegoEv3::Commands::TachoMotor.run_to_abs_pos!(@connection, @id)

      loop do
        break if operation_completed?(old_position)
      end

      position
    end

    # Run to a position relative to the current position.
    # The new position will be *position* + *desired_position*.
    # Then stop using the current stop behavior.
    def run_to_relative_position(desired_position)
      ensure_valid_speed
      old_position = position

      LegoEv3::Commands::TachoMotor.set_position_sp!(@connection, @id, old_position + desired_position)
      LegoEv3::Commands::TachoMotor.run_to_abs_pos!(@connection, @id)

      loop do
        break if operation_completed?(old_position)
      end

      position
    end

    # Run the motor for the amount of time specified in *desired_time_ms*.
    # Then stop using the current stop behavior.
    def run_timed(desired_time_ms)
      ensure_valid_speed
      old_position = position

      LegoEv3::Commands::TachoMotor.set_time_sp!(@connection, @id, desired_time_ms.to_i)
      LegoEv3::Commands::TachoMotor.run_timed!(@connection, @id)

      loop do
        break if operation_completed?(old_position)
      end

      position
    end

    # Run the motor at the *desired_speed*.
    # Unlike other run commands, changing *desired_speed* take immediate effect.
    def run_direct
      LegoEv3::Commands::TachoMotor.run_direct!(@connection, @id)
    end

    def stop
      LegoEv3::Commands::TachoMotor.stop!(@connection, @id)
    end

    def reset
      LegoEv3::Commands::TachoMotor.reset!(@connection, @id)
      sync!
    end

    def ticks_per_rotation(sync = true)
      get_value('@ticks_per_rotation', 'get_count_per_rot', sync)
    end

    def speed(sync = true)
      get_value('@speed', 'get_duty_cycle', sync)
    end

    # This is actually the desired speed but feels more natural.
    def speed=(new_value)
      sanitized = [[new_value.to_i, -100].max, 100].min

      # I will probably learn why this is not right but for now,
      # I sync those 2 values to keep it simple.
      LegoEv3::Commands::TachoMotor.set_speed_sp!(@connection, @id, sanitized)
      LegoEv3::Commands::TachoMotor.set_duty_cycle_sp!(@connection, @id, sanitized)

      desired_speed
    end

    def desired_speed(sync = true)
      get_value('@desired_speed', 'get_duty_cycle_sp', sync)
    end

    def polarity(sync = true)
      get_value('@polarity', 'get_polarity', sync)
    end

    def polarity=(new_value)
      unless [:normal, :inversed].include?(new_value.to_sym)
        raise Exception.new('Invalid polarity. Possible values: :normal, :inversed.')
      end

      LegoEv3::Commands::TachoMotor.set_polarity!(@connection, @id, new_value)
      polarity
    end

    def position(sync = true)
      get_value('@position', 'get_position', sync)
    end

    def position=(new_value)
      LegoEv3::Commands::TachoMotor.set_position!(@connection, @id, new_value.to_i)
      position
    end

    def desired_position(sync = true)
      get_value('@desired_position', 'get_position_sp', sync)
    end

    def desired_time(sync = true)
      get_value('@desired_time', 'get_time_sp', sync)
    end

    def stop_mode(sync = true)
      get_value('@stop_mode', 'get_stop_command', sync)
    end

    def stop_mode=(new_value)
      unless [:coast, :brake, :hold].include?(new_value.to_sym)
        raise Exception.new('Invalid stop behavior. Possible values: :coast, :brake, :hold.')
      end

      LegoEv3::Commands::TachoMotor.set_stop_command!(@connection, @id, new_value)
      stop_mode
    end

    def states
      @states = LegoEv3::Commands::TachoMotor.get_states!(@connection, @id)
    end

    def running
      update_states
      @running
    end

    def ramping
      update_states
      @ramping
    end

    def holding
      update_states
      @holding
    end

    def stalled
      update_states
      @stalled
    end

    def regulated_speed
      @regulated_speed = LegoEv3::Commands::TachoMotor.get_speed_regulation!(@connection, @id)
    end

    def regulated_speed=(new_value)
      LegoEv3::Commands::TachoMotor.set_speed_regulation!(@connection, @id, new_value.kind_of?(TrueClass) ? 'on' : 'off')
      regulated_speed
    end

    def sync!
      ticks_per_rotation(false)
      speed(false)
      desired_speed(false)
      polarity(false)
      position(false)
      desired_position(false)
      desired_time(false)
      stop_mode(false)
      update_states(false)

      @connection.flush("Updated motor state")

      info
    end

    def info
      {
        id: @id,
        port: @port,
        ticks_per_rotation: @ticks_per_rotation,
        speed: @speed,
        desired_speed: @desired_speed,
        position: @position,
        desired_position: @desired_position,
        polarity: @polarity,
        desired_time_ms: @desired_time_ms,
        stop_mode: @stop_mode,
        running: @running,
        ramping: @ramping,
        holding: @holding,
        stalled: @stalled
      }
    end

    private

    def ensure_valid_speed
      throw Exception.new('Speed is set to 0.') if desired_speed == 0
    end

    def update_states(sync = true)
      if sync
        update_states_part_2(LegoEv3::Commands::TachoMotor.get_states!(@connection, @id))
      else
        LegoEv3::Commands::TachoMotor.get_states(@connection, @id) do |states|
          update_states_part_2(states)
        end
      end
    end

    def update_states_part_2(states)
      @running = states.include?(:running)
      @ramping = states.include?(:ramping)
      @holding = states.include?(:holding)
      @stalled = states.include?(:stalled)
    end

    def operation_completed?(old_position)
      update_states

      !@running || @holding
    end

    def get_value(variable_name, command, sync = true)
      if sync
        instance_variable_set(
          variable_name,
          LegoEv3::Commands::TachoMotor.send("#{command}!", @connection, @id))
      else
        LegoEv3::Commands::TachoMotor.send(command, @connection, @id) do |value|
          instance_variable_set(variable_name, value)
        end
      end
    end
  end
end
