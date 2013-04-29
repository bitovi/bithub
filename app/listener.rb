#!/usr/bin/env ruby

app_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require "#{app_root}/config/environment"
require "log4r"

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

  channel.direct("e.events") do |web_exchange|  
    channel.direct("e.events.liveservice") do |liveservice_exchange|
      queue = channel.queue("q.events.web").bind(web_exchange)

      queue.subscribe do |metadata, payload|
        event_hash = ActiveSupport::JSON.decode(payload)
        meta = event_hash.delete('meta')

        begin
          ev = Event.new_from_crawler(event_hash, meta)
          ev.save!
          liveservice_exchange.publish(ev)
        rescue ActiveRecord::RecordInvalid => invalid
          $log.info "Save failed | META: #{meta}"
          $log.info invalid.record.errors.messages.to_yaml
        end
        ev.connection.close
      end
    end
  end
end
