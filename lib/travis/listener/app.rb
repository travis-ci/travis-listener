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
        info "Handling ping for #{credentials.inspect}"
        if sidekiq_active?
          puts "Queueing build via Sidekiq"
          Travis::Sidekiq::BuildRequest.perform_async(data)
        else
          puts "Queueing build via AMQP"
          requests.publish(data, :type => 'request')
        end
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

      def requests
        @requests ||= Travis::Amqp::Publisher.builds('builds.requests')
      end

      def credentials
        login, token = Rack::Auth::Basic::Request.new(env).credentials
        { :login => login, :token => token }
      end

      def payload
        params[:payload]
      end

      def sidekiq_active?
        $redis.get('feature:build_requests_via_sidekiq:enabled') == '1'
      end
    end
  end
end
