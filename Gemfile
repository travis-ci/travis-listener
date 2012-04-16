source :rubygems

gem 'travis-support', git: 'git://github.com/travis-ci/travis-support'

gem 'metriks',        git: 'git://github.com/mattmatt/metriks', ref: 'source'

gem 'sinatra',              '~> 1.3.1'
gem 'rake',                 '~> 0.9.2.2'
gem 'bunny',                '~> 0.7.9'

gem 'activesupport',        '~> 3.2.3'
gem 'hashr',                '~> 0.0.19'

# backports 2.5.0 breaks rails routes
gem 'backports',            '2.4.0'

# structures
gem 'yajl-ruby',            '~> 1.1.0'

# apis
gem 'newrelic_rpm',         '~> 3.3.2'

# heroku
gem 'unicorn',              '~> 4.2.1'

group :development, :test do
  gem 'rspec',              '~> 2.9'
end

group :development do
  gem 'foreman',            '~> 0.41.0'
end

group :test do
  gem 'rack-test'
  gem 'webmock'
end
