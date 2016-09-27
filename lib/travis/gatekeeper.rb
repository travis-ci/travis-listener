module Travis
  module Gatekeeper
    def self.push(queue, *args)
      ::Sidekiq::Client.push(
        'queue' => queue,
        'class' => 'Travis::Gatekeeper::Worker',
        'args' => args
      )
    end
  end
end
