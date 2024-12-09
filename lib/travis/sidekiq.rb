# frozen_string_literal: true

require 'sidekiq'

module Travis
  module Sidekiq

    def self.redis_get_ssl_params(is_gatekeeper)
      gk_string = is_gatekeeper ? '_GATEKEEPER' : ''
      ssl = is_gatekeeper ? Travis.config.redis_gatekeeper.ssl : Travis.config.redis.ssl
      return nil unless ssl

      value = {}
      value[:ca_path] = ENV["REDIS#{gk_string}_SSL_CA_PATH"] if ENV["REDIS#{gk_string}_SSL_CA_PATH"]
      value[:cert] = OpenSSL::X509::Certificate.new(File.read(ENV["REDIS#{gk_string}_SSL_CERT_FILE"])) if ENV["REDIS#{gk_string}_SSL_CERT_FILE"]
      value[:key] = OpenSSL::PKEY::RSA.new(File.read(ENV["REDIS#{gk_string}_SSL_KEY_FILE"])) if ENV["REDIS#{gk_string}_SSL_KEY_FILE"]
      value[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if Travis.config.ssl_verify == false
      value
    end

    class Gatekeeper
      def self.client
        config = Travis.config.redis_gatekeeper.to_h
        config = config.merge(ssl_params: redis_ssl_params) if config[:ssl]
        @@client ||= ::Sidekiq::Client.new(
          pool: ::Sidekiq::RedisConnection.create(
            config
          )
        )
      end

      def self.redis_ssl_params
        @redis_ssl_param ||= Travis::Sidekiq::redis_get_ssl_params(true)
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

      def self.organization(data)
        Metriks.meter('listener.event.organization').mark

        push('sync', :organization, data)
      end

      def self.client
        config = Travis.config.redis.to_h
        config = config.merge(ssl_params: redis_ssl_params) if config[:ssl]
        @@client ||= ::Sidekiq::Client.new(
          pool: ::Sidekiq::RedisConnection.create(config)
        )
      end

      def self.redis_ssl_params
        @redis_ssl_param ||= Travis::Sidekiq::redis_get_ssl_params(false)
      end

      def self.push(queue, *args)
        client.push(
          'queue' => queue,
          'class' => 'Travis::GithubSync::Worker',
          'args' => args.map! { |arg| arg.to_json }
        )
      end
    end
  end
end
