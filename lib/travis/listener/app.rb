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
        # info "## Handling ping ##"

        data = MultiJson.encode({
          :credentials => credentials,
          :request => params[:payload]
        })

        requests.publish(data, :properties => { :type => 'request' })

        # info "## Request created : #{params[:payload].inspect} ##"

        204
      end

      protected

      def requests
        @requests ||= Travis::Amqp::Publisher.builds('builds.requests')
      end

      def credentials
        login, token = Rack::Auth::Basic::Request.new(env).credentials
        { :login => login, :token => token }
      end
    end
  end
end
