require 'redis'
require 'sidekiq'

module Travis
  module Sidekiq
    class Gatekeeper
      def self.client
        @@client ||= ::Sidekiq::Client.new(
          ::Sidekiq::RedisConnection.create(Travis.config.redis_gatekeeper.to_h)
        )
      end

      def self.push(queue, *args)
        client.push(
          'queue' => queue,
          'class' => 'Travis::Gatekeeper::Worker',
          'args' => args
        )
      end
    end

    class GithubSync
      def self.client
        @@client ||= ::Sidekiq::Client.new(
          ::Sidekiq::RedisConnection.create(Travis.config.redis.to_h)
        )
      end

      def self.push(*args)
        client.push(
          'queue' => queue,
          'class' => 'Travis::Github::Sync::Worker',
          'args' => args
        )
      end
    end
  end
end
