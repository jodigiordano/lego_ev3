module LegoEv3
  class LocalConnection < BaseConnection
    def initialize
      super()
      @file_handles = {}
    end

    def close
      @file_handles.values.each do |handle|
        handle.close
      end
    end

    protected

    def create_connection; end

    def call_connection(commands)
      commands.map do |(verb, path, value, handle)|
        if verb == :list then list(path)
        elsif verb == :read then read(path, handle)
        elsif verb == :write then write(path, value, handle)
        else raise new LegoEv3::InvalidCommandException(verb)
        end
      end
    end

    private

    def list(path)
      f = get_folder_handler(path)
      f.map{ |f| f } - ['.', '..']
    rescue
      [] # TODO: Bug? The folder is not created if no sensor plugged in once.
    end

    def read(path, handle)
      f = get_file_handler(path, handle)
      f.rewind
      f.read
    end

    def write(path, value, handle)
      f = get_file_handler(path, handle)
      f.rewind
      f.write(value)
      f.flush
    end

    def get_file_handler(path, handle)
      @file_handles[path] ||= File.open(path, handle)
    end

    def get_folder_handler(path)
      @file_handles[path] ||= Dir.open(path)
    end
  end
end
