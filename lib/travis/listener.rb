require 'travis/support'
require 'travis/listener/config'
require 'travis/listener/app'

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