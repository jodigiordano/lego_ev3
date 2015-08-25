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

    def call_connection(commands)
      begin
        joined_command = join_commands(commands)

        puts "Sending: #{joined_command}"

        responses = @connection
          .ssh(@host, joined_command)
          .stdout
          .split("\n")

        commands.map do |(verb, _, _, _)|
          if verb == :list
            # TODO: Bug? The folder is not created if no sensor plugged in once.
            r = responses.shift
            r.include?('No such file or directory') ? [] : r.split(' ').map(&:strip)
          elsif verb == :read
            responses.shift
          elsif verb == :write
            nil
          else raise new LegoEv3::InvalidCommandException(verb)
          end
        end
      rescue => e
        if e.wrapped.kind_of?(Timeout::Error)
          raise RemoteConnectionException.new(@host, @user, @password)
        else
          raise e
        end
      end
    end

    private

    def join_commands(commands)
      commands.map do |(verb, path, value, _)|
        if verb == :list then list(path)
        elsif verb == :read then read(path)
        elsif verb == :write then write(path, value)
        else raise new LegoEv3::InvalidCommandException(verb)
        end
      end.join(';')
    end

    def list(path)
      "ls -C #{path}"
    end

    def read(path)
      "cat #{path}"
    end

    def write(path, value = nil)
      "echo #{value} > #{path}"
    end
  end
end
