$LISTENER_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
$PROJ_ROOT_DIR = File.expand_path(File.join($LISTENER_DIR, '..', '..'))
$:.unshift($PROJ_ROOT_DIR)

require 'config/environment'
require 'log4r'

require_relative 'helpers'

$log = Log4r::Logger.new('listener')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

class IssueDuplicate < StandardError; end

# Message queue (RabbitMQ) connection and event loop
AMQP.start(ENV['RABBITMQ_URI']) do |connection, open_ok|
  $log.info "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { $log.info "Terminating the listener"; connection.close { EM.stop }}
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)
  channel.direct("e.events") do |input_exchange|

    channel.fanout("e.events.liveservice") do |liveservice_exchange|
      queue = channel.queue("q.events").bind(input_exchange)
      queue.subscribe do |metadata, payload|

        begin
          item_hash = ActiveSupport::JSON.decode(payload)
          processed = Events::Dispatcher.new.process(item_hash)
          $log.info processed
        rescue Events::Errors::UnknownFeedException => e
          $log.error item_hash.inspect
        rescue Events::Errors::UnknownTypeException
          $log.error item_hash.inspect
        end

      end
    end
  end
end
