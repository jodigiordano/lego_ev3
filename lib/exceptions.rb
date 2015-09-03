module LegoEv3
  class RemoteConnectionException < Exception
    def initialize(host, user, password)
      super(
        "Could not connect to the brick. " +
        "Make sure these command works: " +
        "[ping #{host}]" +
        "[ssh #{user}@#{host} + enter your password]")
    end
  end

  class InvalidCommandException < Exception
    def initialize(verb)
      super(
        "The command with verb #{verb} is not supported." +
        "You must implement it.")
    end
  end

  class InvalidModeException < Exception
    def initialize(type, sub_type, mode, valid_modes)
      super(
        "The mode #{mode} is not valid on the #{type} of type #{sub_type}. " +
        "Supported modes are: #{valid_modes}")
    end
  end

  class InvalidChannelException < Exception
    def initialize(channel)
      super(
        "The channel #{channel} is not supported in the mode :control_alt of " +
        "the infrared sensor. The only supported channel is 1."
      )
    end
  end
end
