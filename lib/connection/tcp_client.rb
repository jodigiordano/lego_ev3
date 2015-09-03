require 'socket'
require 'base64'

module LegoEv3
  class TCPConnection < BaseConnection
    def initialize(host)
      super()

      @host = host
    end

    def close
      @connection.close if @connection
      @connection = nil
    end

    protected

    def create_connection
      socket = TCPSocket.new(@host.split(':').first, @host.split(':').last)
      socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      socket
    end

    def call_connection(commands)
      joined_command = join_commands(commands)

      puts "Sending: #{joined_command}"

      @connection.puts(Base64.strict_encode64(Marshal.dump(joined_command)))

      responses = []

      while responses.count < commands.count
        raw = @connection.gets
        response = Marshal.load(Base64.strict_decode64(raw.rstrip))
        puts "Received: #{response}"
        responses << response
      end

      responses
    end

    private

    def join_commands(commands)
      commands
        .map { |command| command.join(';') }
        .join("\n")
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