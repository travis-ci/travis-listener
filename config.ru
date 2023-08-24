# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'travis/listener'

Travis::Listener.setup

use Sentry::Rack::CaptureExceptions if Travis.config.sentry.dsn
run Travis::Listener::App
