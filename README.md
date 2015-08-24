# Lego EV3

## Getting started

### Make sure you have the necessary Ruby dependencies

The [ev3dev.org](http://www.ev3dev.org) distribution contains Ruby 2 but some libraries are missing to build native extensions. *This lib requires native extensions to work*.

Solution #1: Use [RVM](https://rvm.io).
Solution #2: Install those dependencies:

```
apt-get install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool ruby-dev
```

### Install the gem

```
gem install lego-ev3
```

### A simple script

```
require 'lego_ev3'

# The connection class look at the hostname of the machine to determine
# if the connection to establish must be local or remote (ssh).
# machine.hostname != config.hostname => remote.
connection = LegoEv3::Connection.new('ssh' => {
  'host' => '192.168.2.3',
  'hostname' => 'ev3dev',
  'username' => 'root',
  'password' => 'r00tme'
})

brick = LegoEv3::Brick.new(connection)

# Plug the touch sensor in any input and run this script by pressing
# or not the sensor. The 'pressed' value should change accordingly.
s = brick.sensors.first
s.poll
puts s.info.inspect

connection.close
```
