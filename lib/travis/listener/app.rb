require 'sinatra'
require 'travis/support/logging'
require 'sidekiq'
require 'travis/sidekiq/build_request'
require 'newrelic_rpm'
require 'multi_json'
require 'ipaddr'
require 'metriks'

module Travis
  module Listener
    class App < Sinatra::Base
      include Logging

      # use Rack::CommonLogger for request logging
      enable :logging, :dump_errors

      # see https://github.com/github/github-services/blob/master/services/travis.rb#L1-2
      set :events, %w[push pull_request]

      before do
        logger.level = 1
      end

      get '/' do
        redirect "http://about.travis-ci.org"
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
            handle_event

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

      def handle_event
        return unless handle_event?
        debug "Event payload for #{uuid}: #{payload.inspect}"
        log_event(event_details, uuid: uuid, delivery_guid: delivery_guid, type: event_type, repository: slug)
        Travis::Sidekiq::BuildRequest.perform_async(data)
      end

      def handle_event?
        settings.events.include?(event_type)
      end

      def log_event(event_details, event_basics)
        info(event_details.merge(event_basics).map{|k,v| "#{k}=#{v}"}.join(" "))
      end

      def data
        {
          :type => event_type,
          :credentials => credentials,
          :payload => payload,
          :uuid => uuid,
          :github_guid => delivery_guid,
          :github_event => event_type
        }
      end

      def uuid
        @uuid ||= Travis.uuid
      end

      def event_type
        env['HTTP_X_GITHUB_EVENT'] || 'push'
      end

      def event_details
        if event_type == 'pull_request'
          {
            number: decoded_payload['number'],
            action: decoded_payload['action'],
            source: decoded_payload['pull_request']['head']['repo'] && decoded_payload['pull_request']['head']['repo']['full_name'],
            head:   decoded_payload['pull_request']['head']['sha'][0..6],
            ref:    decoded_payload['pull_request']['head']['ref'],
            user:   decoded_payload['pull_request']['user']['login'],
          }
        elsif event_type == 'push'
          {
            ref:     decoded_payload['ref'],
            head:    push_head_commit,
            commits: (decoded_payload["commits"] || []).map {|c| c['id'][0..6]}.join(",")
          }
        end
      rescue => e
        error("Error logging payload: #{e.message}")
        error("Payload causing error: #{decoded_payload}")
        Raven.capture_exception(e)
        {}
      end

      def push_head_commit
        decoded_payload['head_commit'] && decoded_payload['head_commit']['id'] && decoded_payload['head_commit']['id'][0..6]
      end

      def delivery_guid
        env['HTTP_X_GITHUB_GUID']
      end

      def credentials
        login, token = Rack::Auth::Basic::Request.new(env).credentials
        { :login => login, :token => token }
      end

      def payload
        params[:payload]
      end

      def slug
        "#{owner_login}/#{repository_name}"
      end

      def owner_login
        decoded_payload['repository']['owner']['login'] || decoded_payload['repository']['owner']['name']
      end

      def repository_name
        decoded_payload['repository']['name']
      end

      def decoded_payload
        @decoded_payload ||= MultiJson.load(payload)
      end
    end
  end
end
