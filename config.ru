$:.unshift File.expand_path('../lib', __FILE__)

require 'travis/listener'

Travis::Listener.setup
Travis::Listener.connect

use Raven::Rack
run Travis::Listener::App
