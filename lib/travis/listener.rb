require 'travis'
require 'travis/listener/app'

$stdout.sync = true

module Travis
  module Listener
    class << self
      def setup
        Travis::Amqp.config = Travis.config.amqp
      end

      def connect(amqp = false)
        Travis::Amqp.connect if amqp
        Database.connect
      end

      def disconnect
        ActiveRecord::Base.connection.disconnect!
      end
    end
  end
end