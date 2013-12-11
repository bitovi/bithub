$: << File.dirname(__FILE__)

require 'bundler/setup'
require 'amqp'
require 'ponder'
require 'yajl'
require 'log4r'
require 'digest/md5'
require 'time'

# Logging
$log = Log4r::Logger.new('IRC-bot')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# MSGQ connection string
$mq_cs = ENV['RABBITMQ_URI']
$channels = ENV['IRCCHANS'].split(',')
$nicks = []

AMQP.start($mq_cs) do |connection, open_ok|
  channel  = AMQP::Channel.new(connection)
  channel.fanout("e.events.preproc") do |exchange|

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
      now = Time.now.utc

      EM.defer do
        hash_key = Digest::MD5.hexdigest(data[:channel] + data[:nick] + now.to_s)

        msg = {
          :meta => {
            origin_author_name: data[:nick],
            feed: 'irc',
            type: data[:channel].gsub('#',''),
            category: 'chat'
          },
          title: data[:message].body,
          origin_ts: now.iso8601,
          origin_date: Date.today.strftime('%Y-%m-%d'),
          hash_key: hash_key,
          url: "http://webchat.freenode.net/?channels=#{data[:channel].gsub('#','')}"
        }

        $log.info "NEW MSG: #{msg}"
        exchange.publish(Yajl::Encoder.encode(msg), routing_key: "tasks.taggify")
      end
    end

    @thaum.connect

    stop = proc { $log.info "Terminating the IRC bot"; connection.close { EM.stop } }
    Signal.trap("INT",  &stop)
    Signal.trap("TERM", &stop)
  end
end
