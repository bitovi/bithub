$: << File.dirname(__FILE__)

require 'bundler/setup'
require 'amqp'
require 'ponder'
require 'yajl'

# RabbitMQ connection string
$mq_cs = ENV['MSGQ']

AMQP.start($mq_cs) do |connection, open_ok|
  channel  = AMQP::Channel.new(connection)
  exchange = channel.fanout("e.events")

  @thaum = Ponder::Thaum.new do |thaum|
    thaum.nick   = 'bitovi-bot'
    thaum.server = 'irc.freenode.net'
    thaum.port   = 6667
  end

  @thaum.on :connect do
    @thaum.join '#bitovi'
    @thaum.join '#canjs'
  end

  @thaum.on :channel, // do |data|
    data[:time] = Time.now
    EM.defer do
      msg = { 
        actor: data[:user],
        title: data[:message],
        feed: 'irc',
        type: data[:channel],
        timestamp: data[:time]
      }
      exchange.publish(Yajl::Encoder.encode(msg))
    end
  end

  @thaum.connect

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)
end
