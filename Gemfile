source :rubygems

# see https://gist.github.com/2063855
base ||= 'git://github.com/travis-ci'
type = base[0, 2] == '..' ? :path : :git

gem 'travis-core',     type => "#{base}/travis-core", :require => 'travis/engine'
gem 'travis-support',  type => "#{base}/travis-support"

gem 'metriks',        :git => 'git://github.com/mattmatt/metriks.git', :ref => "source"

gem 'sinatra',              '~> 1.3.1'
gem 'rake',                 '~> 0.9.2.2'
gem 'amqp',                 '~> 0.9'

# app
# gem 'devise',             '~> 1.5.0'
# gem 'omniauth-github',    '~> 1.0.0'

# structures
gem 'yajl-ruby',            '~> 1.1.0'
gem 'rabl',                 '~> 0.5.1'

# db
gem 'pg',                   '~> 0.13'
gem 'silent-postgres',      '~> 0.0.8'

# apis
gem 'newrelic_rpm',         '~> 3.3.2'

# heroku
gem 'puma',                 :git => 'git://github.com/evanphx/puma.git'

group :development, :test do
  gem 'rspec',                 '~> 2.9'
  gem 'data_migrations',       '~> 0.0.1'
  gem 'micro_migrations', :git => 'git://gist.github.com/2087829.git'
end


group :development do
  gem 'foreman',            '~> 0.26.1'
end

group :test do
  gem 'database_cleaner',   '~> 0.6.7'
end
