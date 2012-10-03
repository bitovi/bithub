$: << File.dirname(__FILE__)

# Theirs
require 'bundler/setup'
require 'log4r'
require 'yajl'
require 'nokogiri'
require 'nori'
require 'em-http-request'
require 'amqp'
require 'zlib'
require 'base64'

# Ours
require 'handlers'

# Connection string
$mq_cs = ENV['MSGQ']

# Logging
$log = Log4r::Logger.new('crawler')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# Event loop
AMQP.start($mq_cs) do |connection, open_ok|
  channel = AMQP::Channel.new(connection)
  exchange = channel.direct("e.events.preproc")

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  $log.info "Registering Github"
  EM.add_periodic_timer(5, &Handler::Github.handler($log, exchange))

  $log.info "Registering Disqus"
  EM.add_periodic_timer(12, &Handler::Disqus.handler($log, exchange))

  $log.info "Registering Forums"
  EM.add_periodic_timer(17, &Handler::Forums.handler($log, exchange))

  $log.info "Registering Blog"
  EM.add_periodic_timer(22, &Handler::Blog.handler($log, exchange))

  $log.info "Registering Community site"
  EM.add_periodic_timer(47, &Handler::CommunitySite.handler($log, exchange))
end
