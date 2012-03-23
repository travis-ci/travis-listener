require 'sinatra'
require 'active_record'
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
        info "## Handling ping ##"
        ping = Request.create_from(params[:payload], token)
        info "## Request created : #{ping.inspect} ##"
        204
      end

      protected

      def token
        Rack::Auth::Basic::Request.new(env).credentials.last
      end
    end
  end
end
