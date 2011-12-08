$LOAD_PATH.unshift 'lib'

require 'travis/listener'

Travis::Listener.setup

run Travis::Listener::App