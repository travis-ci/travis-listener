$:.unshift File.expand_path('../lib', __FILE__)

require 'travis/listener'

Travis::Listener.setup
Travis::Listener.connect

run Travis::Listener::App
