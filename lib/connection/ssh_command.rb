require 'net/ssh/simple'

module LegoEv3
  class SSHScript
    def initialize(ssh_config, command)
      @ssh_config = ssh_config
      @command = command
    end

    def run
      puts "Connecting to brick..."

      Net::SSH::Simple.sync(@ssh_config) do
        buffer = ''

        puts "Opening Bash session..."

        ssh('ev3', '/bin/sh') do |event, console, d|
          case event
            when :start
              puts "Executing #{@command} locally..."

              console.send_data(@command)
              console.eof!
            when :stdout
              buffer << d
              while line = buffer.slice!(/(.*)\r?\n/) do puts line end
              :no_append
            when :stderr
              while line = buffer.slice!(/(.*)\r?\n/) do puts line end
              :no_append
            when :exit_code
              puts d
            when :exit_signal
              puts d
              :no_raise
            when :finish
              puts "Done."
          end
        end
      end
    end
  end
end
