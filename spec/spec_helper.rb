ENV["RACK_ENV"] ||= 'test'

require 'rack/test'
require 'logger'
require 'webmock/rspec'

require 'travis/listener'
require 'support/webmock'
require 'payloads'

Travis.logger = ::Logger.new(StringIO.new)

Travis::Listener.setup

Support::Webmock.urls = %w(
  https://api.github.com/users/svenfuchs
)

RSpec.configure do |c|
  c.include Rack::Test::Methods

  c.alias_example_to :fit, :focused => true
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true

  c.before :all do
    Support::Webmock.mock!
  end
end
