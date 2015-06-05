ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.join(ROOT_DIR, 'lib', 'logger_factory')
require File.join(ROOT_DIR, 'lib', 'connection_manager')

worker_processes 1
timeout 30
preload_app true

# Unix socket
listen "unix:/tmp/bithub_unicorn.sock", :backlog => 64

# PID
pid "./tmp/pids/unicorn.pid"

logger(LoggerFactory.new('unicorn', :environment => ENV['ENV']).logger)

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
  sleep 1
end

after_fork do |server, worker|
  stop = proc { Process.kill 'QUIT', Process.pid }
  Signal.trap('TERM', &stop)
  Signal.trap('INT', &stop)

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to Postgres (ActiveRecord)')
  end

  if defined?(Bunny)
    ConnectionManager.instance
    Rails.logger.info('Connected to RabbitMQ')
  end

  if defined?(Redis)
    ConnectionManager.instance
    Rails.logger.info('Connected to Redis')
  end
end
