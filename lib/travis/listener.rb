require 'travis/support'
require 'travis/listener/config'
require 'travis/listener/app'
require 'logger'
require 'sidekiq'

$stdout.sync = true

module Travis
  class << self
    def config
      @config ||= Config.new
    end
  end

  module Listener
    class << self
      def setup
        ::Sidekiq.configure_client do |config|
          config.redis = Travis.config.redis.merge(size: 1, namespace: 'sidekiq')
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

      def connect
        $redis = Redis.new(Travis.config.redis)
      end

      def disconnect
        # empty for now
      end
    end
  end
end
