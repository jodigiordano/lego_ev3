module LegoEv3
  module Commands
    module CommandBuilder
      private

      def base_path(path)
        self.define_singleton_method "get_base_path" do
          path
        end

        self.define_singleton_method "get_path" do |id|
          get_base_path + "/#{id}"
        end

        self.define_singleton_method "get_command_path" do |id|
          get_base_path + "/#{id}/command"
        end
      end

      def get(alias_name, type = String, command_name = nil, handle = 'r', processor = nil)
        command_name ||= alias_name

        self.define_singleton_method "get_#{alias_name}" do |connection, id, &callback|
          connection.send(:read, "#{get_path(id)}/#{command_name}", nil, handle) do |response|
            sanitized = (response || '').strip

            if type == Integer
              sanitized = sanitized.to_i
            elsif type == Symbol
              sanitized = sanitized.to_sym
            end

            sanitized = processor.call(sanitized) if processor
            callback.call(sanitized) if callback
          end
        end

        self.define_singleton_method "get_#{alias_name}!" do |connection, id|
          return_value = nil

          self.send("get_#{alias_name}", connection, id) do |response|
            return_value = response
          end

          connection.flush

          return_value
        end
      end

      def set(alias_name, command_name = nil, handle = 'r')
        command_name ||= alias_name

        self.define_singleton_method "set_#{alias_name}" do |connection, id, value|
          connection.send(:write, "#{get_path(id)}/#{command_name}", value.to_s, handle)
        end

        self.define_singleton_method "set_#{alias_name}!" do |connection, id, value|
          self.send("set_#{alias_name}", connection, id, value)
          connection.flush
        end
      end

      def get_set(alias_name, type = String, command_name = nil, processor = nil)
        get(alias_name, type, command_name, 'r+', processor)
        set(alias_name, command_name, 'r+')
      end

      def command(alias_name, command_name = nil)
        command_name ||= alias_name

        self.define_singleton_method alias_name do |connection, id|
          connection.send(:write, get_command_path(id), command_name, 'w')
        end

        self.define_singleton_method "#{alias_name}!" do |connection, id|
          self.send(alias_name, connection, id)
          connection.flush
        end
      end

      def has_list
        self.define_singleton_method :list do |connection, &callback|
          connection.send(:list, get_base_path, nil, 'r') do |response|
            callback.call(response)
          end
        end

        self.define_singleton_method :list! do |connection|
          entries = nil

          list(connection) do |response|
            entries = response
          end

          connection.flush

          entries
        end
      end
    end
  end
end
