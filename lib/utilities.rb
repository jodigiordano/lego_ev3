require 'yaml'

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

  def self.default_user_config
    {
      'ssh' => {
        'host' => '192.168.2.3', # I'm working on Mac OS X, eh.
        'hostname' => 'ev3dev',
        'username' => 'root',
        'password' => 'r00tme'
      }
    }
  end

  def self.load_config(path)
    YAML::load(File.open(path))
  end
end