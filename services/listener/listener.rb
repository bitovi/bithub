LISTENER_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
ROOT_DIR = File.expand_path(File.join(LISTENER_DIR, '..', '..'))
DOMAIN_DIR = File.join(ROOT_DIR, 'app', 'domain')

$:.unshift(ROOT_DIR)
$:.unshift(DOMAIN_DIR)

require 'config/environment'
require_relative 'helpers'
require 'dispatcher'
require 'logger_factory'

logger = LoggerFactory.new('listener', ENV['ENV']).component_logger
$logger = logger

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
