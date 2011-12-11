require 'travis'
require 'travis/listener/app'

$stdout.sync = true

module Travis
  module Listener
    class << self
      def connect
        Travis::Amqp.config = Travis.config.amqp
        Travis::Amqp.connect
        puts "AMQP #{Travis::Amqp.connected? ? 'connected' : 'did not connect'}"
        Database.connect
      end

      def disconnect
        ActiveRecord::Base.connection.disconnect!
      end
    end
  end
end