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

# Config address
config = YAML.load_file('config/config.yml')

# Connection strings
$mq_cs = config[ENV['ENV']]['msg-queue']

# Logging
$log = Log4r::Logger.new('crawler')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

def start_crawler
  # Event loop
  AMQP.start($mq_cs) do |connection, open_ok|
    channel  = AMQP::Channel.new(connection)
    exchange = channel.fanout("e.events", :auto_delete => true)

    stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
    Signal.trap("INT",  &stop)
    Signal.trap("TERM", &stop)

    

    # Testing the queue (sending one message per second)
    # ===
    # send_message = proc do 
    #   exchange.publish(Yajl::Encoder.encode({title: 'Something happen!', link:'http://someaddress.com'}))
    # end
    # EM.add_periodic_timer(1, &send_message)

    $log.info "Registering Github"
    EM.add_periodic_timer(5, &Handler::Github.handler($log, exchange))

    $log.info "Registering Disqus"
    EM.add_periodic_timer(12, &Handler::Disqus.handler($log, exchange))

    $log.info "Registering Forums"
    EM.add_periodic_timer(17, &Handler::Forums.handler($log, exchange))

    $log.info "Registering Blog"
    EM.add_periodic_timer(22, &Handler::Blog.handler($log, exchange))
  end
end
