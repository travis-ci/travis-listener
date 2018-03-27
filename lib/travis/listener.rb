require 'travis/config'
require 'travis/support'
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
      define  redis:            { url: 'redis://localhost:6379', namespace: 'sidekiq', network_timeout: 5 },
              redis_gatekeeper: { url: ENV['REDIS_GATEKEEPER_URL'] || 'redis://localhost:6379', namespace: 'sidekiq', network_timeout: 5 },
              gator:            { queue: ENV['SIDEKIQ_GATEKEEPER_QUEUE'] || 'build_requests' },
              sentry:           { },
              metrics:          { reporter: 'librato' }
    end

    class << self
      def setup
        if Travis.config.sentry.dsn
          require 'raven'
          ::Raven.configure do |config|
            config.dsn = Travis.config.sentry.dsn
            config.excluded_exceptions = %w{Sinatra::NotFound}
          end
        end

        Travis::Metrics.setup if ENV['RACK_ENV'] == "production"
      end

      def disconnect
        # empty for now
      end
    end
  end
end
