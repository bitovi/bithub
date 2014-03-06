LISTENER_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
ROOT_DIR = File.expand_path(File.join(LISTENER_DIR, '..', '..'))
DOMAIN_DIR = File.join(ROOT_DIR, 'app', 'domain')

$:.unshift(ROOT_DIR)
$:.unshift(DOMAIN_DIR)

require 'config/environment'
require_relative 'helpers'
require 'dispatcher'

# Logger
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/rollingfileoutputter'
require 'log4r/outputter/datefileoutputter'

if ENV['ENV'] == 'development'
  logger_config_data = YAML.load_file(File.join(ROOT_DIR, 'config', 'log4r_dev.yml'))
else
  logger_config_data = YAML.load_file(File.join(ROOT_DIR, 'config', 'log4r.yml'))
end

log_cfg = Log4r::YamlConfigurator
log_cfg["ENV"] = ENV['ENV']
log_cfg["MACHINE_NAME"] = ENV["MACHINE_NAME"].nil? ? `hostname`.to_s.gsub(/\n$/, "") : ENV["MACHINE_NAME"] 
log_cfg["COMPONENT_NAME"] = "listener"
log_cfg.decode_yaml(logger_config_data['log4r_config'])
logger = Log4r::Logger['component']

# Message queue (RabbitMQ) connection and event loop
AMQP.start(ENV['RABBITMQ_URI']) do |connection, open_ok|
  logger.info "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  channel = AMQP::Channel.new(connection)
  channel.direct("e.events") do |input_exchange|

    channel.fanout("e.events.liveservice") do |liveservice_exchange|
      queue = channel.queue("q.events").bind(input_exchange)
      queue.subscribe do |metadata, payload|
        response = ActiveSupport::JSON.decode(payload)
        Dispatcher.new.dispatch(response)
      end
    end
  end
end
