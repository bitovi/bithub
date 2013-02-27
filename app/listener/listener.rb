# encoding: UTF-8
rails_app_root = File.expand_path(File.dirname(__FILE__) + '/../..')
require "#{rails_app_root}/config/environment/#{ENV['env']}"

# Logging
log = Log4r::Logger.new('listener')
log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# Message queue (RabbitMQ) connection and event loop
AMQP.start(ENV['CLOUDAMQP_URL']) do |connection, open_ok|
  channel = AMQP::Channel.new(connection)
  queue = channel.queue("q.events.web").bind("e.events")

  queue.subscribe do |metadata, payload|
    EM.defer do
      event = Yajl::Parser.parse(payload)
      log.info event
    end
  end
end

stop = proc { puts "Terminating the listener"; connection.close { EM.stop } }
Signal.trap("INT",  &stop)
Signal.trap("TERM", &stop)
