require 'travis/support'
require 'travis/listener/config'
require 'travis/listener/app'
require 'logger'
require 'metriks'
require 'metriks/reporter/logger'

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

        if ENV['RACK_ENV'] == "production"
          puts 'Starting reporter'
          $metriks_reporter = Metriks::Reporter::Logger.new(:logger => Logger.new($stdout))
        end
      end

      def connect(amqp = false)
        Travis::Amqp.connect if amqp
      end

      def disconnect
        # empty for now
      end
    end
  end
end
