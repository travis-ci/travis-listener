# frozen_string_literal: true

require 'sidekiq'

module Travis
  module Sidekiq
    class Gatekeeper
      def self.client
        @@client ||= ::Sidekiq::Client.new(
          pool: ::Sidekiq::RedisConnection.create(Travis.config.redis_gatekeeper.to_h)
        )
      end

      def self.push(queue, *args)
        client.push(
          'queue' => queue,
          'class' => 'Travis::Gatekeeper::Worker',
          'args' => args.map! { |arg| arg.to_json }
        )
      end
    end

    class GithubSync
      def self.gh_app_install(data)
        Metriks.meter('listener.event.gh_apps_install').mark

        push('sync.gh_apps', :gh_app_install, data)
      end

      def self.gh_app_repos(data)
        Metriks.meter('listener.event.gh_apps_repos').mark

        push('sync.gh_apps', :gh_app_repos, data)
      end

      def self.gh_app_member(data)
        Metriks.meter('listener.event.gh_apps_member').mark

        push('sync', :gh_app_member, data)
      end

      def self.client
        @@client ||= ::Sidekiq::Client.new(
          pool: ::Sidekiq::RedisConnection.create(Travis.config.redis.to_h)
        )
      end

      def self.push(queue, *args)
        client.push(
          'queue' => queue,
          'class' => 'Travis::GithubSync::Worker',
          'args' => args
        )
      end
    end
  end
end
