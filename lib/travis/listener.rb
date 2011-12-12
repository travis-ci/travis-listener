require 'travis'
require 'travis/listener/app'
require 'airbrake'

$stdout.sync = true

module Travis
  module Listener
    class << self
      def setup
        Travis::Amqp.config = Travis.config.amqp

        Airbrake.configure do |config|
          config.api_key = Travis.config.airbrake
        end
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