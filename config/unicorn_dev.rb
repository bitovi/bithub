worker_processes 3
timeout 30
preload_app true

# Unix socket
listen "unix:./tmp/unicorn.sock", :backlog => 64

# PID
pid "./tmp/unicorn.pid"

# Logs
stderr_path "./tmp/unicorn.stderr.log"
stdout_path "./tmp/unicorn.stdout.log"

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end
  sleep 1
end

after_fork do |server, worker|
  stop = proc { puts 'Terminating web service'; Process.kill 'QUIT', Process.pid }
  Signal.trap('TERM', &stop)
  Signal.trap('INT', &stop)

  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end
end
