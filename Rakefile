require 'bundler/setup'

require 'rake'
require 'rspec/core/rake_task'

require 'micro_migrations'
require 'travis'

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb'
end

task :default => :spec
