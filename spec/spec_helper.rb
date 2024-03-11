# frozen_string_literal: true

require 'simplecov'
require 'simplecov-console'

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::Console,
    SimpleCov::Formatter::HTMLFormatter
  ]
)

# Code Coverage check
SimpleCov.start do
  add_filter 'spec'
  add_filter 'vendor/'
end

ENV['RACK_ENV'] ||= 'test'

require 'rack/test'
require 'logger'
require 'travis/listener'
require 'sidekiq/testing'
require 'pry'

Travis.logger = Logger.new(StringIO.new)

Travis::Listener.setup

RSpec.configure do |c|
  c.include Rack::Test::Methods

  c.alias_example_to :fit, focused: true
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
end

require 'timecop'
Timecop.freeze('2022-01-01 00:02:00 +0200')

module Payloads
  def self.load(path)
    File.read(File.expand_path("../payloads/#{path}.json", __FILE__))
  end
end

QUEUE_PAYLOAD = {
  :type => 'push',
  :uuid => Travis.uuid,
  :github_guid => 'abc123',
  :github_event => 'push',
  :received_at => Time.now
}
