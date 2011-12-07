require 'travis'
require 'travis/listener/app'

$stdout.sync = true

module Travis
  module Listener
    def self.setup
      Database.connect
    end
  end
end