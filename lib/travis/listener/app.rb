require 'sinatra'
require 'travis/support/logging'
require 'newrelic_rpm'

module Travis
  module Listener
    class App < Sinatra::Base
      include Logging

      # use Rack::CommonLogger for request logging
      enable :logging, :dump_errors

      # Used for new relic uptime monitoring
      get '/uptime' do
        200
      end

      # the main endpoint for scm services
      post '/' do
        info "Handling ping for #{credentials.inspect}"
        requests.publish(data, :type => 'request')
        debug "Request created : #{payload.inspect}"
        204
      end

      protected

      def data
        {
          :type => env['HTTP_X_GITHUB_EVENT'],
          :credentials => credentials,
          :request => payload
        }
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
    end
  end
end
