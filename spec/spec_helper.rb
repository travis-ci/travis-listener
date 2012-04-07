ENV["RACK_ENV"] ||= 'test'

require 'rack/test'
require 'payloads'
require 'logger'
require 'webmock/rspec'

require 'travis/listener'
require 'support/webmock'

Travis.logger = ::Logger.new(StringIO.new)

Travis::Listener.setup
Travis::Listener.connect

Support::Webmock.urls = %w(
  https://api.github.com/users/svenfuchs
)

RSpec.configure do |c|
  c.include Rack::Test::Methods

  c.alias_example_to :fit, :focused => true
  c.filter_run :focused => true
  c.run_all_when_everything_filtered = true

  c.before :all do
    Support::Webmock.mock!
  end
end

QUEUE_PAYLOAD = {
  :credentials => {
    :login => "user",
    :token => "12345"
  },
  :request => "{\n    \"repository\": {\n      \"url\": \"http://github.com/svenfuchs/gem-release\",\n      \"name\": \"gem-release\",\n      \"owner\": {\n        \"email\": \"svenfuchs@artweb-design.de\",\n        \"name\": \"svenfuchs\"\n      }\n    },\n    \"commits\": [{\n      \"id\":        \"9854592\",\n      \"message\":   \"Bump to 0.0.15\",\n      \"timestamp\": \"2010-10-27 04:32:37\",\n      \"committer\": {\n        \"name\":  \"Sven Fuchs\",\n        \"email\": \"svenfuchs@artweb-design.de\"\n      },\n      \"author\": {\n        \"name\":  \"Christopher Floess\",\n        \"email\": \"chris@flooose.de\"\n      }\n    }],\n    \"ref\": \"refs/heads/master\",\n    \"compare\": \"https://github.com/svenfuchs/gem-release/compare/af674bd...9854592\"\n  }"
}