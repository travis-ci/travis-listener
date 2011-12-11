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
          puts "#{params[:service]} is not supported"
          pass
        end
        puts "handing ping from #{params[:service]} with payload : #{request.body.gets}"
        request = Request.create_from(request.body, token)
        puts "request created : #{request.inspect}"
        204
      end
    end
  end
end