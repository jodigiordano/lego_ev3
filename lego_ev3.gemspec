Gem::Specification.new do |s|
  s.name        = 'lego_ev3'
  s.version     = '0.9.0'
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Library to interface with Lego EV3 starter kit'
  s.description = 'Uses the amazing ev3dev.org stuff to interface with the Lego EV3 starter kit'
  s.authors     = ['Jodi Giordano']
  s.email       = 'giordano.jodi@gmail.com'
  s.homepage    = 'https://github.com/jodigiordano/lego_ev3'
  s.files       = ['Gemfile', 'README.md'] + Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.executables = ['lego-ev3', 'lego-ev3-tcp-server']
  s.license     = 'MIT'

  s.add_runtime_dependency 'net-ssh-simple', '~> 1.6'
end
