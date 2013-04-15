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
require 'rubygems'
require 'exceptional'
require 'json'

# Ours
require 'handlers'
require 'string'

# Connection string
$mq_cs = ENV['RABBITMQ_URI']

# Exceptional
Exceptional::Config.load("config/exceptional.yml")

# Logging
$log = Log4r::Logger.new('crawler')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# Calculate project root path
$proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../'))

# Load feeds config 
$feeds = YAML::load_file(File.join($proj_root, 'config/feeds.yml'))

# Event loop
AMQP.start($mq_cs) do |connection, open_ok|
  puts "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)
  exchange = channel.direct("e.events.preproc")

  # --- Streams
  $log.info "Registering to Twitter's public stream"
  Handler::Twitter.connect($log, exchange, $feeds[:twitter][:streams][:public_feed], false)

  $log.info "Registering @canjs user stream"
  Handler::Twitter.connect($log, exchange, $feeds[:twitter][:streams][:canjs], true)

  $log.info "Registering @jquerypp user stream"
  Handler::Twitter.connect($log, exchange, $feeds[:twitter][:streams][:jquerypp], true)

  $log.info "Registering @funcunit user stream"
  Handler::Twitter.connect($log, exchange, $feeds[:twitter][:streams][:funcunit], true)
  
  $log.info "Registering @javascriptmvc user stream"
  Handler::Twitter.connect($log, exchange, $feeds[:twitter][:streams][:javascriptmvc], true)
  
  $log.info "Registering @donejs user stream"
  Handler::Twitter.connect($log, exchange, $feeds[:twitter][:streams][:donejs], true)

  Exceptional.rescue do
    # --- Pollers
    $log.info "Registering Github"
    EM.add_periodic_timer(6, &Handler::Github.handler($log, exchange))
    
    $log.info "Registering Disqus"
    EM.add_periodic_timer(11, &Handler::Disqus.handler($log, exchange))
    
    $log.info "Registering Forums"
    forum_endpoints = {
      questions: 'https://forum.javascriptmvc.com/feed/filter/questions',
      all: 'https://forum.javascriptmvc.com/feed'
    }
    EM.add_periodic_timer(25, &Handler::Forums.handler($log, exchange, forum_endpoints))
    
    $log.info "Registering Blog"
    EM.add_periodic_timer(31, &Handler::Blog.handler($log, exchange))
    
    $log.info "Registering Community site"
    EM.add_periodic_timer(46, &Handler::CommunitySite.handler($log, exchange))
  end
end
