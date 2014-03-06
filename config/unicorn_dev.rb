ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

worker_processes 3
timeout 30
preload_app true

# Unix socket
listen "unix:./tmp/sockets/unicorn.sock", :backlog => 64

# PID
pid "./tmp/pids/unicorn.pid"

# Logging
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/rollingfileoutputter'
require 'log4r/outputter/datefileoutputter'

logger_config_data = YAML.load_file(File.join(ROOT_DIR, 'config', 'log4r_dev.yml'))
log_cfg = Log4r::YamlConfigurator
log_cfg["ENV"] = ENV['ENV']
log_cfg["COMPONENT_NAME"] = "unicorn"
log_cfg.decode_yaml(logger_config_data['log4r_config'])

# Set the logger
logger(Log4r::Logger['component'])

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

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end
end
