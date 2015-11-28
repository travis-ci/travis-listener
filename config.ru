$:.unshift File.expand_path('../lib', __FILE__)

require 'travis/listener'

Travis::Listener.setup

use Raven::Rack if Travis.config.sentry.dsn
run Travis::Listener::App
