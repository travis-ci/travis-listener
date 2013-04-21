source 'https://rubygems.org'

ruby '1.9.3'

gem 'travis-support',  github: 'travis-ci/travis-support'
gem 'travis-sidekiqs', github: 'travis-ci/travis-sidekiqs', require: nil

gem 'metriks',         '~> 0.9.7.3'
gem 'sinatra',         '~> 1.4.2'
gem 'rake',            '~> 0.9.2.2'
gem 'redis'
gem 'multi_json'

gem 'sentry-raven',    github: 'getsentry/raven-ruby'

gem 'activesupport',   '~> 3.2.13'
gem 'hashr',           '~> 0.0.19'

# backports 2.5.0 breaks rails routes
gem 'backports',       '2.4.0'

# structures
gem 'yajl-ruby',       '~> 1.1.0'

# apis
gem 'newrelic_rpm',    '~> 3.6.0'

# heroku
gem 'unicorn',         '~> 4.6.2'

group :development, :test do
  gem 'rspec',         '~> 2.9'
end

group :development do
  gem 'foreman',       '~> 0.41.0'
end

group :test do
  gem 'rack-test'
  gem 'webmock'
end
