# frozen_string_literal: true

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
        check_run
        check_suite
        create
        delete
        installation
        installation_repositories
        member
        organization
        pull_request
        push
        repository
        release
      ]

      before do
        logger.level = 1
      end

      get '/' do
        redirect 'http://travis-ci.com'
      end

      # Used for new relic uptime monitoring
      get '/uptime' do
        200
      end

      # the main endpoint for scm services
      post '/' do
        report_memory_usage
        report_ip_validity
        replace_bot_sender

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
        Travis.config.listener&.ip_validation
      end

      def replace_bot_sender
        return unless payload && decoded_payload.dig('sender', 'type')&.downcase == 'bot'

        payload_data = JSON.parse(payload)
        payload_data['sender'] = {
          type: 'User',
          github_id: 0,
          vcs_id: '0',
          login: 'bot'
        }
        params[:payload] = JSON.dump(payload_data)
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
        Travis.config.listener&.valid_ips || []
      end

      def dispatch_event
        Metriks.meter("listener.event.#{event_type}").mark
        Metriks.meter("listener.integration.#{integration_type}").mark

        return unless handle_event?

        return if release_event_skip_action?

        # According to GitHub every webhook payload should have this
        # If it is not present, assume payload is malformed
        return unless payload['sender']

        debug "Event payload for #{uuid}: #{payload.inspect}"

        log_event

        case event_type
        when 'installation'
          Travis::Sidekiq::GithubSync.gh_app_install(data)
        when 'installation_repositories'
          Travis::Sidekiq::GithubSync.gh_app_repos(data)
        when 'member'
          Travis::Sidekiq::GithubSync.gh_app_member(data)
        when 'organization'
          Travis::Sidekiq::GithubSync.organization(data)
        else
          Travis::Sidekiq::Gatekeeper.push(Travis.config.gator.queue, data)
        end
      end

      def handle_event?
        if accepted_event_excluding_checks? || rerequested_check?
          Metriks.meter('listener.handle.accept').mark
          true
        else
          Metriks.meter('listener.handle.reject').mark
          false
        end
      end

      def accepted_event_excluding_checks?
        settings.events.include?(event_type) && !checks_event?
      end

      # there are two types of rerequested events
      # 1. for branches
      # 2. for tags (when tags are created)
      # we ignore the tag events because we also receive individual
      # tag created events.
      def rerequested_check?
        checks_event? &&
          decoded_payload['action'] == 'rerequested' &&
          !tag_created_check_suite?
      end

      def checks_event?
        %w[check_run check_suite].include?(event_type)
      end

      def tag_created_check_suite?
        event_type == 'check_suite' &&
          decoded_payload['check_suite']['ref_type'] == 'tag'
      end

      def release_event_skip_action?
        event_type == 'release' &&
          decoded_payload['action'] != 'released'
      end

      def log_event
        details = {
          uuid:,
          delivery_guid:,
          type: event_type
        }

        info(details.merge(event_details).map { |k, v| "#{k}=#{v}" }.join(' '))
      end

      def data
        {
          type: event_type,
          payload:,
          uuid:,
          github_guid: delivery_guid,
          github_event: event_type,
          received_at: Time.now
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
        if params[:payload].blank?
          'github_apps'
        else
          'webhook'
        end
      end

      def event_details
        Schemas.event_details(event_type, decoded_payload)
      rescue StandardError => e
        error("Error logging payload: #{e.message}")
        error("Payload causing error: #{decoded_payload}")
        Sentry.capture_exception(e)
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
            when 'check_suite'
              Schemas::CHECK_SUITE
            when 'create', 'delete', 'repository', 'check_run'
              Schemas::REPOSITORY
            when 'member'
              Schemas::MEMBER
            when 'release'
              Schemas::RELEASE
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
        end
      end

      def request_body
        @request_body ||= begin
          request.body.rewind
          request.body.read.force_encoding('utf-8')
        end
      end

      def report_memory_usage
        Metriks.gauge('listener.gc.heap_live_slots').set(GC.stat[:heap_live_slots])
      end
    end
  end
end
