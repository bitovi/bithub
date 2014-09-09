ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.join(ROOT_DIR, 'lib', 'logger_factory')

worker_processes 1
timeout 30
preload_app true

# Unix socket
listen "unix:./tmp/sockets/unicorn.sock", :backlog => 64

# PID
pid "./tmp/pids/unicorn.pid"

logger(LoggerFactory.new('unicorn', :environment => ENV['ENV']).component_logger)

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end
  sleep 1
end

after_fork do |server, worker|
  stop = proc { Process.kill 'QUIT', Process.pid }
  Signal.trap('TERM', &stop)
  Signal.trap('INT', &stop)

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end
end
