worker_processes 3
timeout 30
preload_app true

# Unix socket
listen "/home/bithub/web/shared/sockets/unicorn.sock", :backlog => 64

# PID
pid "/home/bithub/web/shared/pids/unicorn.pid"

# Logs
stderr_path "/home/bithub/web/shared/log/unicorn.stderr.log"
stdout_path "/home/bithub/web/shared/log/unicorn.stdout.log"

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
