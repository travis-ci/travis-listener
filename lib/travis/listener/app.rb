require 'sinatra'

module Travis
  module Listener
    class App < Sinatra::Base
      post '/' do
        "Hello World!"
      end
    end
  end
end