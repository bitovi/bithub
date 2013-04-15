# encoding: UTF-8
rails_app_root = File.expand_path(File.dirname(__FILE__) + '/..')
ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'
require "#{rails_app_root}/config/environment"
require "./app/models/event"

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
        ev = Event.new_with_checks(event_hash, meta)
        ev.save
        ev.connection.close
      end
    end
  end
  
end

