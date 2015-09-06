require 'yaml'
require 'optparse'

module LegoEv3
  # bar, time = with_timer do
  #   foo()
  # end
  #
  def self.with_timer(&block)
    start = Time.now

    return_value = block.call

    finish = Time.now
    diff = finish - start

    [return_value, (diff * 1000).to_i] # in ms.
  end

  def self.user_config_overrides
    @@user_config_overrides
  end

  def self.user_config_overrides=(new_value)
    @@user_config_overrides = new_value
  end

  # 1. Start from a default config + programatic config
  # 2. If a config is found in the command parameters, apply overrides.
  # 3. If a config is found in LegoEv3::resolved_config, apply overrides.
  def self.resolve_user_config(user_config = nil)
    config = default_user_config.merge(user_config || {})

    OptionParser.new do |opt|
      opt.on('-c, --config PATH', 'Use the provided configuration at PATH.') do |path|
        config.merge!(LegoEv3::load_config(path))
      end
    end.parse!

    config.merge!(user_config_overrides || {})

    user_config_overrides = config

    config
  end

  def self.default_user_config
    {
      'entry_point' => 'script.rb',
      'remote' => {
        'host' => '192.168.2.3', # I'm working on Mac OS X, eh.
        'hostname' => 'ev3dev',
        'username' => 'root',
        'password' => 'r00tme',
        'ssh' => 22,
        'tcp' => 13603,
        'service' => 'ssh'
      }
    }
  end

  def self.load_config(path)
    YAML::load(File.open(path))
  end

  private

  @@user_config_overrides = nil
end