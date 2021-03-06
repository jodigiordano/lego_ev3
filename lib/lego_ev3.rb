def require_all_relative(directory)
  Dir[File.join(File.dirname(__FILE__), directory, '**', '*.rb')].each do |file|
    require file
  end
end

require_relative 'utilities'
require_relative 'exceptions'

require_relative 'commands/builder'
require_all_relative 'commands'

require_relative 'connection/base'
require_all_relative 'connection'

require_relative 'sensors/base'
require_all_relative 'sensors'

require_relative 'tacho_motor'
require_relative 'brick'
