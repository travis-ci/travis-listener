source 'https://rubygems.org'

ruby '2.5.8'

gem 'travis-support',  git: 'https://github.com/travis-ci/travis-support', ref: '113cff17fe383bb72fcfae3a97a8ce98c228342f'
gem 'travis-config',   '~> 1.0.0'

gem 'sidekiq',         '~> 6.4.0'
gem 'redis-namespace'

gem 'puma',            '~> 4'
gem 'sinatra',         '~> 2.0.3'
gem 'rake',            '~> 12.3.3'

gem 'sentry-raven'

gem 'activesupport',   '~> 5'

gem 'json'
gem 'metriks'
gem 'metriks-librato_metrics'

gem 'yajl-ruby',       '~> 1.4.0'

gem 'jemalloc',        git: 'https://github.com/joshk/jemalloc-rb'

group :development, :test do
  gem 'pry'
  gem 'rspec',         '~> 2.9'
end

group :development do
  gem 'foreman',       '~> 0.41.0'
end

group :test do
  gem 'rack-test'
end
