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

$failover_tags = ['canjs','donejs','stealjs','javascriptmvc','jquerypp','documentjs','shouldjs','jquery++']
# $failover_tags = ['jquery', 'javascript']

public_stream_opts = {
  :path   => '/1.1/statuses/filter.json',
  :params => { :track => $failover_tags.join(',') },
  :oauth  => {
    :consumer_key     => ENV['PUBLIC_FEED_CONSUMER_KEY'],
    :consumer_secret  => ENV['PUBLIC_FEED_CONSUMER_SECRET'],
    :token            => ENV['PUBLIC_FEED_OAUTH_TOKEN'],
    :token_secret     => ENV['PUBLIC_FEED_OAUTH_TOKEN_SECRET']
  }
}

canjs_user_stream_opts = {
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

jquerypp_user_stream_opts = {
  :host   => 'userstream.twitter.com',
  :method => 'GET',
  :path   => '/1.1/user.json',
  :oauth  => {
    :consumer_key     => ENV['JQUERYPP_CONSUMER_KEY'],
    :consumer_secret  => ENV['JQUERYPP_CONSUMER_SECRET'],
    :token            => ENV['JQUERYPP_OAUTH_TOKEN'],
    :token_secret     => ENV['JQUERYPP_OAUTH_TOKEN_SECRET']
  }
}

funcunit_user_stream_opts = {
  :host   => 'userstream.twitter.com',
  :method => 'GET',
  :path   => '/1.1/user.json',
  :oauth  => {
    :consumer_key     => ENV['FUNCUNIT_CONSUMER_KEY'],
    :consumer_secret  => ENV['FUNCUNIT_CONSUMER_SECRET'],
    :token            => ENV['FUNCUNIT_OAUTH_TOKEN'],
    :token_secret     => ENV['FUNCUNIT_OAUTH_TOKEN_SECRET']
  }
}

javascriptmvc_user_stream_opts = {
  :host   => 'userstream.twitter.com',
  :method => 'GET',
  :path   => '/1.1/user.json',
  :oauth  => {
    :consumer_key     => ENV['JAVASCRIPTMVC_CONSUMER_KEY'],
    :consumer_secret  => ENV['JAVASCRIPTMVC_CONSUMER_SECRET'],
    :token            => ENV['JAVASCRIPTMVC_OAUTH_TOKEN'],
    :token_secret     => ENV['JAVASCRIPTMVC_OAUTH_TOKEN_SECRET']
  }
}

shouldjs_user_stream_opts = {
  :host   => 'userstream.twitter.com',
  :method => 'GET',
  :path   => '/1.1/user.json',
  :oauth  => {
    :consumer_key     => ENV['SHOULDJS_CONSUMER_KEY'],
    :consumer_secret  => ENV['SHOULDJS_CONSUMER_SECRET'],
    :token            => ENV['SHOULDJS_OAUTH_TOKEN'],
    :token_secret     => ENV['SHOULDJS_OAUTH_TOKEN_SECRET']
  }
}

donejs_user_stream_opts = {
  :host   => 'userstream.twitter.com',
  :method => 'GET',
  :path   => '/1.1/user.json',
  :oauth  => {
    :consumer_key     => ENV['DONEJS_CONSUMER_KEY'],
    :consumer_secret  => ENV['DONEJS_CONSUMER_SECRET'],
    :token            => ENV['DONEJS_OAUTH_TOKEN'],
    :token_secret     => ENV['DONEJS_OAUTH_TOKEN_SECRET']
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
  $log.info "Registering to Twitter's public stream"
  Handler::Twitter.connect($log, exchange, public_stream_opts, false)

  $log.info "Registering @canjs user stream"
  Handler::Twitter.connect($log, exchange, canjs_user_stream_opts, true)

  $log.info "Registering @jquerypp user stream"
  Handler::Twitter.connect($log, exchange, jquerypp_user_stream_opts, true)

  $log.info "Registering @funcunit user stream"
  Handler::Twitter.connect($log, exchange, funcunit_user_stream_opts, true)
  
  $log.info "Registering @javascriptmvc user stream"
  Handler::Twitter.connect($log, exchange, javascriptmvc_user_stream_opts, true)
  
  $log.info "Registering @donejs user stream"
  Handler::Twitter.connect($log, exchange, donejs_user_stream_opts, true)

  # --- Pollers
  $log.info "Registering Github"
  EM.add_periodic_timer(6, &Handler::Github.handler($log, exchange, 'https://api.github.com/orgs/bitovi/events'))

  $log.info "Registering Disqus"
  EM.add_periodic_timer(11, &Handler::Disqus.handler($log, exchange))


  $log.info "Registering Forums"
  forum_endpoints = {
    questions: 'https://forum.javascriptmvc.com/feed/filter/questions',
    ideas: 'https://forum.javascriptmvc.com/feed/filter/ideas',
    all: 'https://forum.javascriptmvc.com/feed'
  }
  EM.add_periodic_timer(5, &Handler::Forums.handler($log, exchange, forum_endpoints))

  $log.info "Registering Blog"
  EM.add_periodic_timer(31, &Handler::Blog.handler($log, exchange))

  $log.info "Registering Community site"
  EM.add_periodic_timer(46, &Handler::CommunitySite.handler($log, exchange))
end
