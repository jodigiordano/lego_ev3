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
end
