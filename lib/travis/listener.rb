require 'travis/support'
require 'travis/listener/config'
require 'travis/listener/app'
require 'logger'
require 'metriks'
require 'metriks/reporter/logger'
require 'raven'
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
        Travis::Amqp.config = Travis.config.amqp
        ::Sidekiq.configure_client do |config|
          config.redis = Travis.config.redis.merge(size: 1, namespace: 'sidekiq')
        end

        ::Raven.configure do |config|
          config.dsn = Travis.config.sentry.dsn
        end

        if ENV['RACK_ENV'] == "production"
          puts 'Starting reporter'
          formatter = lambda do |severity, date, progname, message|
            "#{message}\n"
          end
          logger = Logger.new($stdout)
          logger.formatter = formatter
          $metriks_reporter = Metriks::Reporter::Logger.new(:logger => logger, :on_error => lambda{|ex| puts ex})
        end
      end

      def connect(amqp = false)
        Travis::Amqp.connect if amqp
        $redis = Redis.new(Travis.config.redis)
      end

      def disconnect
        # empty for now
      end
    end
  end
end
