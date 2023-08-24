# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.5.9'

gem 'travis-support', git: 'https://github.com/travis-ci/travis-support',
                      ref: '113cff17fe383bb72fcfae3a97a8ce98c228342f'
gem 'travis-config',   '~> 1.0.0'

gem 'sidekiq',         '~> 4.0.0'
gem 'redis-namespace'

gem 'puma'
gem 'sinatra',         '~> 2.0.3'
gem 'rake',            '~> 12.3.3'

gem 'sentry-raven'

gem 'activesupport', '~> 4.1.11'

gem 'metriks'
gem 'metriks-librato_metrics'

gem 'yajl-ruby',       '~> 1.4.0'

gem 'jemalloc',        git: 'https://github.com/travis-ci/jemalloc-rb', branch: 'jemalloc-5.0'

group :development, :test do
  gem 'pry'
  gem 'rspec'
end

group :development do
  gem 'foreman', '~> 0.41.0'
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
