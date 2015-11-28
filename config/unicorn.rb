worker_processes Integer(ENV.fetch('WEB_CONCURRENCY', 2))
timeout Integer(ENV.fetch('UNICORN_TIMEOUT', 15))

preload_app true

before_fork do |server, worker|
  Travis::Listener.disconnect
end

after_fork do |server, worker|
  if reporter = Travis::Metrics.reporter
    reporter.stop
    reporter.start
  end
end
