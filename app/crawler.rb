$: << File.dirname(__FILE__)

# Theirs
require 'bundler/setup'
require 'log4r'
require 'yajl'
require 'nokogiri'
require 'nori'
require 'amqp'
require 'zlib'
require 'base64'

# Ours
require 'handlers'
require 'string'

# Connection string
$mq_cs = ENV['MSGQ']

# Logging
$log = Log4r::Logger.new('crawler')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

$failover_tags = ['canjs','donejs','stealjs','javascriptmvc','jquerypp','documentjs','shouldjs']
# $failover_tags = ['jquery', 'javascript']

public_stream_opts = {
  # :host   => 'sitestream.twitter.com',
  :path   => '/1.1/statuses/filter.json',
  :params => { :track => $failover_tags.join(',') },
  :oauth  => {
    :consumer_key     => ENV['CANJS_CONSUMER_KEY'],
    :consumer_secret  => ENV['CANJS_CONSUMER_SECRET'],
    :token            => ENV['CANJS_OAUTH_TOKEN'],
    :token_secret     => ENV['CANJS_OAUTH_TOKEN_SECRET']
  }
}

user_stream_opts = {
  :host   => 'userstream.twitter.com',
  :method => 'GET',
  :path   => '/1.1/user.json',
  :oauth  => {
    :consumer_key     => ENV['CANJS_CONSUMER_KEY'],
    :consumer_secret  => ENV['CANJS_CONSUMER_SECRET'],
    :token            => ENV['CANJS_OAUTH_TOKEN'],
    :token_secret     => ENV['CANJS_OAUTH_TOKEN_SECRET']
  }
}

# Event loop
AMQP.start($mq_cs) do |connection, open_ok|
  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)
  exchange = channel.direct("e.events.preproc")

  # --- Streams
  $log.info "Registering public stream"
  Handler::Twitter.connect($log, exchange, public_stream_opts)

  $log.info "Registering @canjs user stream"
  Handler::Twitter.connect($log, exchange, user_stream_opts)

  # --- Pollers
  $log.info "Registering Github"
  EM.add_periodic_timer(6, &Handler::Github.handler($log, exchange))

  $log.info "Registering Disqus"
  EM.add_periodic_timer(11, &Handler::Disqus.handler($log, exchange))

  $log.info "Registering Forums"
  EM.add_periodic_timer(23, &Handler::Forums.handler($log, exchange))

  $log.info "Registering Blog"
  EM.add_periodic_timer(31, &Handler::Blog.handler($log, exchange))

  $log.info "Registering Community site"
  EM.add_periodic_timer(46, &Handler::CommunitySite.handler($log, exchange))
end
