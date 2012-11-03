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

twitter_options = {
  :path   => '/1/statuses/filter.json',
  :params => { :track => 'canjs,donejs,javascriptmvc,jvmc,jquerypp' },
  :oauth  => {
    :consumer_key     => ENV['TWITTER_CONSUMER_KEY'],
    :consumer_secret  => ENV['TWITTER_CONSUMER_SECRET'],
    :token            => ENV['TWITTER_OAUTH_TOKEN'],
    :token_secret     => ENV['TWITTER_OAUTH_TOKEN_SECRET']
  }
}

# Event loop
AMQP.start($mq_cs) do |connection, open_ok|
  channel = AMQP::Channel.new(connection)
  exchange = channel.direct("e.events.preproc")
  client = EM::Twitter::Client.connect(twitter_options)

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  # --- Streamers
  client.each do |result|
    $log.info "twitter: new event at "
    Handler::Twitter.handle_event($log, exchange, result)
  end

  client.on_error do |message|
    $log.error "oops: error: #{message}"
  end

  client.on_unauthorized do
    $log.error "oops: unauthorized"
  end

  client.on_forbidden do
    $log.error "oops: unauthorized"
  end

  client.on_not_found do
    $log.error "oops: not_found"
  end

  client.on_not_acceptable do
    $log.error "oops: not_acceptable"
  end

  client.on_too_long do
    $log.error "oops: too_long"
  end

  client.on_range_unacceptable do
    $log.error "oops: range_unacceptable"
  end

  client.on_enhance_your_calm do
    $log.error "oops: enhance_your_calm"
  end

  client.on_service_unavailable do
    $log.error "oops: service_unavailable"
  end

  client.on_reconnect do
    $log.error "oops: reconnect"
  end

  client.on_max_reconnects do
    $log.error "oops: max_reconnects"
  end

  client.on_close do
    $log.error "oops: close"
  end

  client.on_no_data_received do
    $log.error "oops: no_data_received"
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
