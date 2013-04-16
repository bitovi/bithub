$: << File.dirname(__FILE__)

require 'bundler/setup'
require 'sinatra'
require 'amqp'
require 'ponder'
require 'yajl'
require 'log4r'
require 'digest/md5'
  
# Logging
$log = Log4r::Logger.new('IRC-bot')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# MSGQ connection string
$mq_cs = ENV['RABBITMQ_URI']
$channels = ENV['IRCCHANS'].split(',')
$nicks = []

# API calls available
class API < Sinatra::Base
  get '/nicks' do
    Yajl::Encoder.encode($nicks.uniq)
  end
end

EM.next_tick do
  AMQP.connect($mq_cs) do |connection, open_ok|
    channel  = AMQP::Channel.new(connection)
    exchange = channel.direct("e.events.preproc")

    @thaum = Ponder::Thaum.new do |thaum|
      thaum.nick   = ENV['NICK']
      thaum.server = 'irc.freenode.net'
      thaum.port   = 6667
    end

    @thaum.on :connect do
      EM::Iterator.new($channels).each do |c, iter| 
        @thaum.join '#' + c
        iter.next
      end
    end

    @thaum.on :part do |data|
      nick = data[:part].user.nick
      $nicks.delete(nick)
      $log.info "ALL: #{$nicks}"
    end


    @thaum.on :join do |data|
      @thaum.user_list.users.each do |u|
        $nicks.push(u.nick)
      end
      $nicks.uniq!
      $log.info "ALL: #{$nicks}"
    end

    @thaum.on :channel, // do |data|
      data[:time] = Time.now.strftime("%FT%T%z")
      hash_key = Digest::MD5.hexdigest(data[:channel] + data[:nick] + data[:time])

      EM.defer do
        msg = { 
          actor: data[:nick],
          title: data[:message],
          feed: 'irc',
          type: data[:channel],
          timestamp: data[:time],
          hash_key: hash_key,
          link: "http://webchat.freenode.net/?channels=#{data[:channel].gsub('#','')}"
        }

        exchange.publish(Yajl::Encoder.encode(msg), routing_key: "tasks.taggify")
      end
    end

    @thaum.connect

    stop = proc { $log.info "Terminating the IRC bot"; connection.close { EM.stop } }
    Signal.trap("INT",  &stop)
    Signal.trap("TERM", &stop)
  end
end
