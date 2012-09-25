$: << File.dirname(__FILE__)

require 'bundler/setup'
require 'amqp'
require 'ponder'
require 'yajl'

# Config address
config = YAML.load_file('config.yml')

# Connection strings
$mq_cs = config[ENV['ENV']]['msg-queue']

def start_bot
  AMQP.start($mq_cs) do |connection, open_ok|
    channel  = AMQP::Channel.new(connection)
    exchange = channel.fanout("e.events")

    @thaum = Ponder::Thaum.new do |thaum|
      thaum.nick   = 'feeder-em-bot'
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
end
