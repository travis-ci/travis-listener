$LOAD_PATH.unshift 'lib'

require 'travis/listener'

Travis::Listener.connect

run Travis::Listener::App