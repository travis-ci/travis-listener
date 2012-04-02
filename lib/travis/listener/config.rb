require 'hashr'
require 'yaml'
require 'active_support/core_ext/object/blank'

# Encapsulates the configuration necessary for travis-core.
#
# Configuration values will be read from
#
#  * either ENV['travis_config'] (this variable is set on Heroku by `travis config [env]`,
#    see travis-cli) or
#  * a local file config/travis.yml which contains the current env key (e.g. development,
#    production, test)
#
# The env key can be set through various ENV variables, see Travis::Config.env.
#
# On top of that the database configuration can be overloaded by setting a database URL
# to ENV['DATABASE_URL'] or ENV['SHARED_DATABASE_URL'] (which is something Heroku does).
module Travis
  class Config < Hashr
    class << self
      def env
       ENV['ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      end

      def load_env
        @load_env ||= YAML.load(ENV['travis_config']) if ENV['travis_config']
      end

      def load_file
        @load_file ||= YAML.load_file(filename)[env] if File.exists?(filename) rescue {}
      end

      def filename
        @filename ||= File.expand_path('config/travis.yml')
      end
    end

    define  :amqp          => { :username => 'guest', :password => 'guest', :host => 'localhost', :prefetch => 1 },
            :async         => {},
            :notifications => [],
            :queues        => [],
            :ssl           => {}

    default :_access => [:key]

    def initialize(data = nil, *args)
      data ||= self.class.load_env || self.class.load_file || {}
      super
    end

    def env
      self.class.env
    end
  end
end