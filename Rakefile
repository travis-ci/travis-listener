require 'bundler/setup'

require 'rake'
require 'rspec/core/rake_task'

require 'micro_migrations'
require 'travis'

ENV['SCHEMA'] = "#{Gem.loaded_specs['travis-core'].full_gem_path}/db/schema.rb"

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb'
end

task :default => :spec
