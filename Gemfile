# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'activesupport',   '~> 7'
gem 'sinatra',         '~> 3'
gem 'rake',            '~> 13'

gem 'redis-namespace'
gem 'travis-support',  github: 'travis-ci/travis-support'
gem 'travis-config',   github: 'travis-ci/travis-config'
gem 'travis-metrics',  github: 'travis-ci/travis-metrics'

gem 'sidekiq',         '~> 7'
gem 'puma',            '~> 4'

gem 'sentry-ruby'

gem 'metriks', github: 'travis-ci/metriks', branch: 'prd-ruby-upgrade-dev'
gem 'metriks-librato_metrics', github: 'travis-ci/metriks-librato_metrics'

gem 'json'

gem 'yajl-ruby',       '~> 1.4.1'
gem 'jemalloc', github: 'travis-ci/jemalloc-rb', branch: 'jemalloc-5.0'

group :development, :test do
  gem 'pry'
  gem 'rspec',          '~> 3'
end

group :development do
  gem 'foreman',        '~> 0.87'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'rack-test'
  gem 'timecop'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end
