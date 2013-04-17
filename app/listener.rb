# encoding: UTF-8
rails_app_root = File.expand_path(File.dirname(__FILE__) + '/..')
ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'

require "log4r"
require "#{rails_app_root}/config/environment"
require "./app/models/event"

$log = Log4r::Logger.new('tagger')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# Message queue (RabbitMQ) connection and event loop
AMQP.start(ENV['RABBITMQ_URI']) do |connection, open_ok|
  
  stop = proc { puts "Terminating the listener"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)

  channel.direct("e.events") do |exchange|  
    queue = channel.queue("q.events.web").bind(exchange)
    queue.subscribe do |metadata, payload|
      EM.defer do
        event_hash = ActiveSupport::JSON.decode(payload)
        meta = event_hash.delete('meta')

        $log.info "New event | META: #{meta}"

        ev = Event.new_with_checks(event_hash, meta)
        ev.save
        ev.connection.close
      end
    end
  end
  
end

