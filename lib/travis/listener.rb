require 'travis'
require 'travis/listener/app'

$stdout.sync = true

module Travis
  module Listener
    def self.setup
      Travis::Amqp.config = Travis.config.amqp
      Travis::Amqp.connect
      Database.connect
    end
  end
end