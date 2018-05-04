require 'travis/listener/schemas'
require 'sinatra'
require 'travis/support/logging'
require 'sidekiq'
require 'travis/sidekiq'
require 'yajl'
require 'ipaddr'
require 'metriks'

module Travis
  module Listener
    class App < Sinatra::Base
      include Logging

      # use Rack::CommonLogger for request logging
      enable :logging, :dump_errors

      # https://developer.github.com/v3/activity/events/types
      set :events, %w[
        push
        pull_request
        create
        delete
        repository
        installation
        installation_repositories
      ]

      before do
        logger.level = 1
      end

      get '/' do
        redirect "http://travis-ci.com"
      end

      # Used for new relic uptime monitoring
      get '/uptime' do
        200
      end

      # the main endpoint for scm services
      post '/' do
        report_ip_validity
        if !ip_validation? || valid_ip?
          if valid_request?
            dispatch_event

            204
          else
            Metriks.meter('listener.request.no_payload').mark

            422
          end
        else
          403
        end
      end

      protected

      def valid_request?
        payload
      end

      def ip_validation?
        (Travis.config.listener && Travis.config.listener.ip_validation)
      end

      def report_ip_validity
        if valid_ip?
          Metriks.meter('listener.ip.valid').mark
        else
          Metriks.meter('listener.ip.invalid').mark
          logger.info "Payload to travis-listener sent from an invalid IP(#{request.ip})"
        end
      end

      def valid_ip?
        return true if valid_ips.empty?

        valid_ips.any? { |ip| IPAddr.new(ip).include? request.ip }
      end

      def valid_ips
        (Travis.config.listener && Travis.config.listener.valid_ips) || []
      end

      def dispatch_event
        Metriks.meter("listener.event.#{event_type}").mark
        Metriks.meter("listener.integration.#{integration_type}").mark

        return unless handle_event?

        debug "Event payload for #{uuid}: #{payload.inspect}"

        log_event

        case event_type
        when 'installation'
          Travis::Sidekiq::GithubSync.gh_app_install(data)
        when 'installation_repositories'
          Travis::Sidekiq::GithubSync.gh_app_repos(data)
        else
          Travis::Sidekiq::Gatekeeper.push(Travis.config.gator.queue, data)
        end
      end

      def handle_event?
        if settings.events.include?(event_type)
          Metriks.meter("listener.handle.accept").mark
          true
        else
          Metriks.meter("listener.handle.reject").mark
          false
        end
      end

      def log_event
        details = {
          uuid:          uuid,
          delivery_guid: delivery_guid,
          type:          event_type
        }

        info(details.merge(event_details).map{|k,v| "#{k}=#{v}"}.join(" "))
      end

      def data
        {
          :type         => event_type,
          :payload      => payload,
          :uuid         => uuid,
          :github_guid  => delivery_guid,
          :github_event => event_type,
        }
      end

      def uuid
        env['HTTP_X_REQUEST_ID'] || Travis.uuid
      end

      def event_type
        env['HTTP_X_GITHUB_EVENT'] || 'push'
      end

      def delivery_guid
        env['HTTP_X_GITHUB_DELIVERY'] || env['HTTP_X_GITHUB_GUID']
      end

      def integration_type
        if !params[:payload].blank?
          "webhook"
        else
          "github_apps"
        end
      end

      def event_details
        Schemas.event_details(event_type, decoded_payload)
      rescue => e
        error("Error logging payload: #{e.message}")
        error("Payload causing error: #{decoded_payload}")
        Raven.capture_exception(e)
        {}
      end

      def decoded_payload
        @decoded_payload ||= begin
          schema = 
            case event_type
            when 'push'
              Schemas::PUSH
            when 'pull_request'
              Schemas::PULL_REQUEST
            when 'installation', 'installation_repositories'
              Schemas::INSTALLATION
            when 'create', 'delete', 'repository'
              Schemas::REPOSITORY
            else
              Schemas::FALLBACK
            end

          stream = StringIO.new(payload)
          Yajl::Projector.new(stream).project(schema)
        end
      end

      def payload
        if !params[:payload].blank?
          params[:payload]
        elsif !request_body.blank?
          request_body
        else
          nil
        end
      end

      def request_body
        @_request_body ||= begin
          request.body.rewind
          request.body.read.force_encoding("utf-8")
        end
      end
    end
  end
end
