$: << File.dirname(__FILE__)

require 'bundler/setup'
require 'amqp'
require 'ponder'
require 'yajl'
require 'log4r'

# Logging
$log = Log4r::Logger.new('IRC-bot')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# RabbitMQ connection string
$mq_cs = ENV['MSGQ']
$irc_chans = ENV['IRCCHANS']

AMQP.start($mq_cs) do |connection, open_ok|
  channel  = AMQP::Channel.new(connection)
  exchange = channel.direct("e.events.preproc")

  @thaum = Ponder::Thaum.new do |thaum|
    thaum.nick   = 'bitovi-bot'
    thaum.server = 'irc.freenode.net'
    thaum.port   = 6667
  end

  @thaum.on :connect do
    $irc_chans.split(',').each{|x| @thaum.join x }
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
      exchange.publish(Yajl::Encoder.encode(msg), routing_key: "tasks.taggify")
    end
  end

  @thaum.connect

  stop = proc { $log.info "Terminating the IRC bot"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)
end
