require 'sinatra'
require 'airbrake'

module Travis
  module Listener
    class App < Sinatra::Base
      include Logging

      # use Rack::CommonLogger for request logging
      set :logging, true

      # Airbrake error notifications
      use Airbrake::Rack


      get '/uptime' do
        200
      end

      post '/:service' do
        unless service_supported?
          info "#{params[:service]} is not supported"
          pass
        end
        info "## Handling ping from #{params[:service]} ##"
        ping = Request.create_from(params[:payload], token)
        info "## Request created : #{ping.inspect} ##"
        204
      end

      protected

      def service_supported?(service = params[:service])
        Request::Payload.constants.any? { |n| n.to_s.downcase == service }
      end

      def token
        Rack::Auth::Basic::Request.new(env).credentials.last
      end
    end
  end
end