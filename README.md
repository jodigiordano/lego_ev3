# Lego EV3

This library leverages the [ev3dev.org](http://www.ev3dev.org) project to provide a dead simple way to program the Lego Mindstorms EV3 starter kit in Ruby.

## Getting started

    gem install lego_ev3

Then:

    mkdir example
    touch example/script.rb
    touch example/config.yml

Put in `script.rb`:

    require 'lego_ev3'

    connection = LegoEv3::Connection.new

    brick = LegoEv3::Brick.new(connection)

    # Plug any sensor in any input.
    s = brick.sensors.first

    100.times do
      puts s.poll
    end

    connection.close

Put in `config.yml`:

    entry_point: script.rb
    remote:
      host: '192.168.2.3'
      hostname: 'ev3dev'
      username: 'root'
      password: 'r00tme'
      ssh: 22
      tcp: 13603
      service: 'ssh'

Execute the script with:

    lego-ev3 example -R

This will open an SSH connection to the brick to send commands. This is one way of doing things, read below for more options.

## Setup the brick to use Ruby

### Make sure you have the necessary dependencies

The [ev3dev.org](http://www.ev3dev.org) distribution contains Ruby 2 but some libraries are missing to build native extensions. **Running local scripts with this lib requires native extensions to work**.

Solution #1: Use [RVM](https://rvm.io).

Solution #2: Install those dependencies:

    apt-get install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool ruby-dev

### (Optional) Faster `gem install` operations

To install gems faster, make sure your `~/.gemrc` on the brick looks like:

    ---
    :verbose: true
    :sources:
    - http://rubygems.org/
    :update_sources: true
    :backtrace: false
    :bulk_threshold: 1000
    :benchmark: false
    gem: --no-ri --no-rdoc --verbose

## Running a script remotely on the brick for debugging

This is the mode used in _Getting started_ above.
This mode requires `remote.service: 'ssh'` in the config.

* [+] No need to setup the brick to use Ruby
* [+] No need to send files to the brick
* [+] Can use breakpoints in script using [Pry](https://github.com/pry/pry)
* [-] The slowest approach (~200 ms per command)

Execute the script with:

    lego-ev3 example -R

## Running a script locally on the brick

The same script in _Getting started_ above can be ran locally on the brick without modifying the code.

* [-] Need to setup the brick to use Ruby
* [-] Need to send files to the brick
* [-] Cannot use breakpoints in script
* [+] Fastest approach (~0.7 ms per command)

Sending a script to the brick:

    lego-ev3 example -u -r

This will:

* Upload the script to the brick (`-u`) at `/home/example`.
* Execute `ruby /home/example/script.rb` through an SSH connection and capture the output.

**How can the same code be used remotely and locally?**

The `LegoEv3::Connection` class is smart enough to determine if the script being executed is on your machine or directly on the brick. To accomplish this, this class uses the `hostname` parameter in the config.

## Running a script remotely on the brick for a test run

* [-] Need to setup the brick to use Ruby
* [+] No need to send files to the brick
* [+] Can use breakpoints in script using [Pry](https://github.com/pry/pry)
* [+] Slow approach (~40 ms per command)

This mode requires `remote.service: 'tcp'` in the config.

    lego-ev3 example -s # Spawn the TCP server on the brick
    lego-ev3 example -R # Execute the script with a TCP client

Note that the TCP server is spawned in background on the brick.
To spawn it in foreground, you need to connect to the brick.

## TODO

* Add a DSL on top of current lib
* Add a state machine on top of current lib
* Use the state machine to produce graphs of robot logic
* Add logging and easy way to produce sensor graphs
* Polling sensors should probably be multi-threaded
* Add examples
