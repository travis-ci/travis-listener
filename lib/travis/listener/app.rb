require 'sinatra'

module Travis
  module Listener
    class App < Sinatra::Base
      set :logging, true

      def service_supported?(service = params[:service])
        Request::Payload.constants.any? { |n| n.to_s.downcase == service }
      end

      def token
        Rack::Auth::Basic::Request.new(env).credentials.last
      end

      post '/:service' do
        unless service_supported?

          pass
        end
        Request.create_from(request.body, token)
        204
      end
    end
  end
end