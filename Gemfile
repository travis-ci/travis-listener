# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

gem 'travis-support',  git: 'https://github.com/travis-ci/travis-support', branch: 'prd-ruby-upgrade-dev'
gem 'travis-config',   git: 'https://github.com/travis-ci/travis-config', branch: 'prd-ruby-upgrade-dev'

gem 'sidekiq',         '~> 7'

gem 'puma'
gem 'sinatra',         '~> 3'
gem 'rake',            '~> 13'

gem 'sentry-ruby'

gem 'activesupport',    '~> 7'
gem 'redis'

gem 'metriks'
gem 'metriks-librato_metrics'

gem 'yajl-ruby',        '~> 1.4'

group :development, :test do
  gem 'pry'
  gem 'rspec',         '~> 3'
end

group :development do
  gem 'foreman',       '~> 0.87'
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
