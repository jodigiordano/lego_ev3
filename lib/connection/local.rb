module LegoEv3
  class LocalConnection < BaseConnection

    def close; end

    protected

    def create_connection; end

    def call_connection(command)
      `command`
    end
  end
end
