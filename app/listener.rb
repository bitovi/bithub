# encoding: UTF-8
rails_app_root = File.expand_path(File.dirname(__FILE__) + '/..')
ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'
require "#{rails_app_root}/config/environment"

# Message queue (RabbitMQ) connection and event loop
AMQP.start(ENV['CLOUDAMQP_URL']) do |connection, open_ok|
  channel = AMQP::Channel.new(connection)
  queue = channel.queue("q.events.web").bind("e.events")

  queue.subscribe do |metadata, payload|
    EM.defer do
      event = ActiveSupport::JSON.decode(payload)
      Rails.logger.info event
    end
  end
end

stop = proc { puts "Terminating the listener"; connection.close { EM.stop } }
Signal.trap("INT",  &stop)
Signal.trap("TERM", &stop)
