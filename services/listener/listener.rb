LISTENER_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
ROOT_DIR = File.expand_path(File.join(LISTENER_DIR, '..', '..'))
DOMAIN_DIR = File.join(ROOT_DIR, 'app', 'domain')

$:.unshift(ROOT_DIR)
$:.unshift(DOMAIN_DIR)

require 'config/environment'
require 'log4r'

require_relative 'helpers'
require 'dispatcher'

config_data = YAML.load_file(File.join(ROOT_DIR, 'config', 'log4r.yml'))
log_cfg = YamlConfigurator
log_cfg["ENV"] = Rails.env 
log_cfg["MACHINE_NAME"] = ENV["MACHINE_NAME"].nil? ? `hostname`.to_s.gsub(/\n$/, "") : ENV["MACHINE_NAME"] 
log_cfg["COMPONENT_NAME"] = "listener"
log_cfg.decode_yaml(config_data['log4r_config'])


# Message queue (RabbitMQ) connection and event loop
AMQP.start(ENV['RABBITMQ_URI']) do |connection, open_ok|
  logger.info "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { logger.info "Terminating the listener"; connection.close { EM.stop }}
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

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
