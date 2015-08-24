module LegoEv3
  class BaseConnection
    def initialize
      @to_send = []
    end

    def send(command, &callback)
      @to_send << [command, callback]
    end

    def flush
      @connection ||= create_connection

      joined_command = @to_send
        .map{ |(c, _)| c }
        .join(';')

      callbacks = @to_send
        .map{ |(_, c)| c }

      joined_response, time = LegoEv3::with_timer do
        call_connection(joined_command)
      end

      puts "#{joined_command}. #{time} ms."

      # We assume that one command output one line of result.
      responses = joined_response.split("\n")

      callbacks.each_with_index.each do |c, i|
        c.call(responses[i]) if c
      end

      @to_send.clear
    end
  end
end