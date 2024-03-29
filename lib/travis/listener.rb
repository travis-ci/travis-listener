# frozen_string_literal: true

require 'travis/config'
require 'travis/support'
require 'travis/metrics'
require 'travis/listener/app'
require 'logger'

$stdout.sync = true

module Travis
  class << self
    def config
      @config ||= Listener::Config.load
    end
  end

  module Listener
    class Config < Travis::Config
      define redis: { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379'), network_timeout: 5 },
             redis_gatekeeper: { url: ENV.fetch('REDIS_GATEKEEPER_URL', 'redis://localhost:6379'), network_timeout: 5 },
             gator: { queue: ENV.fetch('SIDEKIQ_GATEKEEPER_QUEUE', 'build_requests') },
             sync: { queue: ENV.fetch('SIDEKIQ_SYNC_QUEUE', 'sync.gh_apps') },
             sentry: {},
             metrics: { reporter: 'librato' }
    end

    class << self
      def setup
        if Travis.config.sentry.dsn
          require 'sentry-ruby'

          ::Sentry.init do |config|
            config.dsn = Travis.config.sentry.dsn
            config.excluded_exceptions = %w[Sinatra::NotFound]
          end
        end

        return unless ENV.fetch('RACK_ENV', nil) == 'production'

        Travis::Metrics.setup(Travis.config.metrics, Travis::Logger.new($stdout))
      end

      def disconnect
        # empty for now
      end
    end
  end
end
