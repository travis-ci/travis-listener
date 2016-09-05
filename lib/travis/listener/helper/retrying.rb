module Travis
  module Listener
    module Retrying
      def retrying(opts = { max: 5, wait: 0.75 })
        retries ||= 0
        yield
      rescue Redis::BaseError => e
        raise if retries >= opts[:max]
        retries += 1
        puts "#{e.class.name}: #{e.message}. Retrying #{retries}/#{opts[:max]}."
        sleep opts[:wait] * 2 ** (retries - 1) # back off 0.75, 1.5, 3.0, 6.0, 12.0s
        retry
      end

      extend self
    end
  end
end
