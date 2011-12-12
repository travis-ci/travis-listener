require 'travis'
require 'travis/listener/app'

$stdout.sync = true

module Travis
  module Listener
    class << self
      def connect(amqp = false)
        Travis::Amqp.config = Travis.config.amqp
        Travis::Amqp.connect if amqp
        Database.connect
      end

      def disconnect
        ActiveRecord::Base.connection.disconnect!
      end
    end
  end
end