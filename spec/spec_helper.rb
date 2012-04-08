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
  :request => {
    "repository" => {
      "url" => "http://github.com/svenfuchs/gem-release",
      "name" => "gem-release",
      "owner" => {
        "email" => "svenfuchs@artweb-design.de",
        "name" => "svenfuchs"
      }
    },
    "commits" => [
      {
        "id" => "9854592",
        "message" => "Bump to 0.0.15",
        "timestamp" => "2010-10-27 04:32:37",
        "committer" => {
          "name" => "Sven Fuchs",
          "email" => "svenfuchs@artweb-design.de"
        },
        "author" => {
          "name" => "Christopher Floess",
          "email" => "chris@flooose.de"
        }
      }
    ],
    "ref" => "refs/heads/master",
    "compare" => "https://github.com/svenfuchs/gem-release/compare/af674bd...9854592"
  }
}