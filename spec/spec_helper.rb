ENV["RACK_ENV"] ||= 'test'

require 'rack/test'
require 'logger'
require 'travis/listener'
require 'sidekiq/testing'
require 'pry'

Travis.logger = ::Logger.new(StringIO.new)

Travis::Listener.setup

RSpec.configure do |c|
  c.include Rack::Test::Methods

  c.alias_example_to :fit, :focused => true
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end

module Payloads
  def self.load(path)
    File.read(File.expand_path("../payloads/#{path}.json", __FILE__))
  end
end

QUEUE_PAYLOAD = {
  :type => 'push',
  :uuid => Travis.uuid,
  :github_guid => 'abc123',
  :github_event => 'push'
}