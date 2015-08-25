module LegoEv3
  class BaseConnection
    def initialize
      @to_send = []
    end

    def send(verb, path, value = nil, handle = 'r+', &callback)
      @to_send << [[verb, path, value, handle], callback]
    end

    def flush(summary = nil)
      @connection ||= create_connection

      commands = @to_send.map{ |(c, _)| c }
      callbacks = @to_send.map{ |(_, c)| c }

      responses, time = LegoEv3::with_timer do
        call_connection(commands)
      end

      summary ||= commands
        .map{ |c| "[#{c.join(' ')}]" }
        .join(' ')

      puts "#{summary}. #{time} ms."

      callbacks.each_with_index.each do |c, i|
        c.call(responses[i]) if c
      end

      @to_send.clear
    end
  end
end