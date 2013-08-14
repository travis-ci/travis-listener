require 'travis/support'
require 'travis/listener/config'
require 'travis/listener/app'
require 'logger'
require 'metriks'
require 'metriks/librato_metrics_reporter'
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

        if ENV['RACK_ENV'] == "production"
          if Travis.config.librato
            puts 'Starting Librato Metriks reporter'
            email, token = Travis.config.librato.email, Travis.config.librato.token
            source = "#{Travis.config.librato_source}.#{ENV['DYNO']}"
            $metriks_reporter = Metriks::LibratoMetricsReporter.new(email, token, source: source)
            $metriks_reporter.start
          else
            puts 'Librato config missing, Metriks reporter not started'
          end
        end
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
