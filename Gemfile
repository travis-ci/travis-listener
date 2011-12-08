source :rubygems

gem 'sinatra',              '~> 1.3.1'
gem 'rake',                 '~> 0.9.2.2'

gem 'travis-support', :git => 'git://github.com/travis-ci/travis-support.git'
gem 'travis-core',    :git => 'git://github.com/travis-ci/travis-core.git', :require => 'travis_core/engine'

gem 'pusher',               '~> 0.8.5'
gem 'amqp',                 '~> 0.8.3'

# app
# gem 'devise',             '~> 1.5.0'
# gem 'omniauth-github',    '~> 1.0.0'

# structures
gem 'yajl-ruby',            '~> 1.1.0'
gem 'rabl',                 '~> 0.5.1'

# db
gem 'pg',                   '~> 0.11.0'
gem 'silent-postgres',      '~> 0.0.8'

# apis
# gem 'hoptoad_notifier',   '~> 2.4.11'
# gem 'newrelic_rpm',       '~> 3.3.0'

# heroku
gem 'unicorn',              '~> 4.1.1'

group :development, :test do
  gem 'rspec',              '~> 2.7.0'
end

group :development do
  gem 'foreman',               '~> 0.26.1'
  gem 'data_migrations',       '~> 0.0.1'
  gem 'standalone_migrations', '~> 1.0.5'

  unless RUBY_VERSION == '1.9.3' && RUBY_PLATFORM !~ /darwin/
    # will need to install ruby-debug19 manually:
    # gem install ruby-debug19 -- --with-ruby-include=$rvm_path/src/ruby-1.9.3-preview1
    gem 'ruby-debug19', :platforms => :mri_19
  end
end

group :test do
  gem 'database_cleaner',   '~> 0.6.7'
end