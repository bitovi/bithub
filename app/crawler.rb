$: << File.dirname(__FILE__)

# Theirs
require 'bundler/setup'
require 'log4r'
require 'yajl'
require 'nokogiri'
require 'nori'
require 'em-http-request'
require 'em-twitter'
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

site_stream_opts = {
  :host   => 'sitestream.twitter.com',
  :path   => '/1/statuses/filter.json',
  :params => { :track => 'canjs,donejs,stealjs,javascriptmvc,jmvc,jquerypp,documentjs,shouldjs' },
  # :params => { :track => 'jquery,javascript' }, // FOR TESTING
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

  # --- User stream ---
  user_stream_client = EM::Twitter::Client.connect(user_stream_opts)
  user_stream_client.each do |result|
    # $log.info "something on twitter happen"
    Handler::Twitter.handle_user_stream_event($log, exchange, result)
  end
  
  user_stream_client.on_error do |message|
    $log.error "user stream oops: error: #{message}"
  end

  # --- Site stream ---
  site_stream_client = EM::Twitter::Client.connect(site_stream_opts)
  site_stream_client.each do |result|
    $log.info "a new tweet appears #{result}"
    Handler::Twitter.handle_site_stream_event($log, exchange, result)
  end

  site_stream_client.on_error do |message|
    $log.error "site stream oops: error: #{message}"
  end

  # dynamically assign the rest of the errbacks
  
  clients = [user_stream_client, site_stream_client]
  errbacks = [ "on_unauthorized", "on_forbidden",
    "on_not_found", "on_not_acceptable",
    "on_too_long", "on_no_data_received",
    "on_close", "on_max_reconnects",
    "on_enhance_your_calm", "on_service_unavailable", 
    "on_range_unacceptable", "on_reconnect"
  ]


  clients.each do |client|
    errbacks.each do |errback|
      client.send(errback.to_sym) do
        $log.error "#{client} stream oops: #{errback}"
      end
    end
  end

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
