require 'socket'
require 'base64'

module LegoEv3
  class TCPServer
    def initialize(port)
      @port = port
      @local_connection = LegoEv3::LocalConnection.new
    end

    def open
      @server = ::TCPServer.new(@port)

      hostname = `hostname`.strip

      puts "Started TCP server on #{hostname}:#{@port}."
      puts "Waiting for clients..."
      puts "Press CTRL+C to interrupt at any time."

      loop do
        client = @server.accept
        client.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        puts "Client connected."

        while raw_request = client.gets
          request = Marshal.load(Base64.strict_decode64(raw_request.rstrip))
          puts "Received: #{request}"

          receive_commands(request).each do |(verb, path, value, handle)|
            @local_connection.send(verb.to_sym, path, value, handle) do |response|
              puts "Sending: #{response}"
              client.puts(Base64.strict_encode64(Marshal.dump(response)))
            end
          end

          @local_connection.flush
        end

        client.close
        puts "Client closed."
      end
    rescue SystemExit, Interrupt
      close
    end

    def close
      @server.close if @server
      @server = nil

      @local_connection.close if @local_connection
      @local_connection = nil
    end

    private

    def receive_commands(raw)
      raw
        .strip
        .split("\n")
        .map{ |c| c.split(';') }
    end
  end
end
