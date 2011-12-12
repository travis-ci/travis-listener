ENV["RACK_ENV"] ||= 'test'

require 'rack/test'
require 'payloads'
require 'logger'
require 'database_cleaner'


require 'travis/listener'

Travis.logger = ::Logger.new(StringIO.new)

Travis::Listener.setup
Travis::Listener.connect


DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean_with :truncation


RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.before(:each) { DatabaseCleaner.clean }
  config.alias_example_to :fit, :focused => true
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
end