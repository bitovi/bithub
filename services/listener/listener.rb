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
          event_hash = ActiveSupport::JSON.decode(payload)
          new_event = Events::Dispatcher.new(Event).persist(event_hash)

          if new_event.save
            $log.info "Event saved!"
          else
            $log.error new_event.errors.messages
          end
        rescue Events::Errors::UnknownFeedException => e
          $log.error e
          $log.error event_hash.inspect
        rescue Events::Errors::UnknownTypeException => e
          $log.error e
          $log.error event_hash.inspect
        end

      end
    end
  end
end
