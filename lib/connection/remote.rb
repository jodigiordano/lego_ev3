require 'net/ssh/simple'

module LegoEv3
  class RemoteConnection < BaseConnection
    attr_accessor :timeout

    def initialize(host, user, password)
      super()

      @host = host
      @user = user
      @password = password
      @timeout = 10
    end

    def close
      @connection.close if @connection
      @connection = nil
    end

    protected

    def create_connection
      Net::SSH::Simple.new(host_name: @host, user: @user, password: @password, timeout: @timeout)
    end

    def call_connection(command)
      begin
        @connection.ssh(@host, command).stdout
      rescue => e
        if e.wrapped.kind_of?(Timeout::Error)
          raise RemoteConnectionException.new(@host, @user, @password)
        else
          raise e
        end
      end
    end
  end
end
