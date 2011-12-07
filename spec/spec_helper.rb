ENV["RAILS_ENV"] ||= 'test'

require 'rack/test'
require 'payloads'

require 'travis/listener'

Travis.logger = Logger.new(StringIO.new)

Travis::Listener.setup

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

