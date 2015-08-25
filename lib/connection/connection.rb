require 'optparse'

module LegoEv3
  class Connection
    def initialize(user_config = {})
      options = {
        user_config: LegoEv3::default_user_config.merge(user_config)
      }

      OptionParser.new do |opt|
        opt.on('-c, --config PATH', 'Use the provided configuration at PATH.') do |path|
          options[:user_config].merge!(LegoEv3::load_config(path))
        end
      end.parse!
      is_local = `hostname`.strip == options[:user_config]['ssh']['hostname']

      @inner_connection = if is_local
        LegoEv3::LocalConnection.new
      else
        LegoEv3::RemoteConnection.new(
          options[:user_config]['ssh']['host'],
          options[:user_config]['ssh']['username'],
          options[:user_config]['ssh']['password']
        )
      end
    end

    def send(verb, path, value = nil, handle = 'r+', &callback)
      @inner_connection.send(verb, path, value, handle, &callback)
    end

    def flush
      @inner_connection.flush
    end

    def close
      @inner_connection.close
    end

    protected

    def create_connection
      @inner_connection.create_connection
    end

    def call_connection(command)
      @inner_connection.call_connection(command)
    end
  end
end
