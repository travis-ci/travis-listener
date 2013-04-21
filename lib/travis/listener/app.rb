require 'sinatra'
require 'travis/support/logging'
require 'sidekiq'
require 'travis/sidekiq/build_request'
require 'newrelic_rpm'

module Travis
  module Listener
    class App < Sinatra::Base
      include Logging

      # use Rack::CommonLogger for request logging
      enable :logging, :dump_errors

      # see https://github.com/github/github-services/blob/master/services/travis.rb#L1-2
      set :events, %w[push pull_request]

      # Used for new relic uptime monitoring
      get '/uptime' do
        200
      end

      # the main endpoint for scm services
      post '/' do
        handle_event if settings.events.include? event_type
        204
      end

      protected

      def handle_event
        info "Handling ping for #{credentials.inspect} for #{slug}"
        Travis::Sidekiq::BuildRequest.perform_async(data)
        debug "Request created: #{payload.inspect}"
      end

      def data
        {
          :type => event_type,
          :credentials => credentials,
          :payload => payload,
          :uuid => Travis.uuid
        }
      end

      def event_type
        env['HTTP_X_GITHUB_EVENT'] || 'push'
      end

      def credentials
        login, token = Rack::Auth::Basic::Request.new(env).credentials
        { :login => login, :token => token }
      end

      def payload
        params[:payload]
      end

      def slug
        debug payload.inspect
        debug "'repository' : #{payload['repository'].inspect}"
        debug ":repository : #{payload[:repository].inspect}"
        "#{owner_name}/#{repository_name}"
      end

      def owner_name
        payload['repository']['owner']
      end

      def repository_name
        payload['repository']['name']
      end
    end
  end
end
