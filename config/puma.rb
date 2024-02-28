# frozen_string_literal: true

workers Integer(ENV.fetch('WEB_CONCURRENCY', nil) || 2)
threads_count = Integer(ENV.fetch('RAILS_MAX_THREADS', nil) || 5)
threads threads_count, threads_count

preload_app!

port        ENV.fetch('PORT', nil)     || 3000
environment ENV.fetch('RACK_ENV', nil) || 'development'
