LISTENER_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
ROOT_DIR = File.expand_path(File.join(LISTENER_DIR, '..', '..'))
DOMAIN_DIR = File.join(ROOT_DIR, 'app', 'domain')

$:.unshift(ROOT_DIR)
$:.unshift(DOMAIN_DIR)

require 'config/environment'
require 'log4r'

require_relative 'helpers'
require 'dispatcher'

logger = Log4r::Logger.new('listener')
logger.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

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
        begin
          response = ActiveSupport::JSON.decode(payload)
          Dispatcher.new.dispatch(response)
        rescue ActiveRecord::RecordInvalid => err
          logit(logger, err, payload)
        rescue Events::InitializationError => err
          logit(logger, err, payload)
        end
      end
    end
  end
end
