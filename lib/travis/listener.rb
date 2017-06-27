require 'travis/config'
require 'travis/support'
require 'travis/listener/app'
require 'logger'
require 'sidekiq'

$stdout.sync = true

module Travis
  class << self
    def config
      @config ||= Listener::Config.load
    end
  end

  module Listener
    class Config < Travis::Config
      define  redis:          { url: 'redis://localhost:6379', namespace: 'sidekiq', network_timeout: 5 },
              listener_redis: { url: 'redis://localhost:6379', namespace: 'sidekiq', network_timeout: 5 },
              gator:          { queue: ENV['SIDEKIQ_GATEKEEPER_QUEUE'] || 'build_requests' },
              sentry:         { },
              metrics:        { reporter: 'librato' }
    end

    class << self
      def setup
        ::Sidekiq.configure_client do |config|
          if ENV['LISTENER_REDIS_ENABLED'] == 'true'
            config.redis = Travis.config.listener_redis.to_h
          else
            config.redis = Travis.config.redis.to_h
          end
        end

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
