$: << File.expand_path(File.join(File.dirname(__FILE__), '../'))

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
require 'json'
require 'sanitize'

# Ours
require 'app/handlers'
require 'lib/string'
require 'lib/proc'
require 'lib/hash'

# Connection string
$mq_cs = ENV['RABBITMQ_URI']

# Logging
$log = Log4r::Logger.new('crawler')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# Load feeds config 
$feeds = YAML::load_file('config/feeds.yml')

# Event loop
AMQP.start($mq_cs) do |connection, open_ok|
  puts "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)
  channel.fanout("e.events.preproc") do |exchange|

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

    # --- Pollers
    phase = 1; shift_phase = lambda {phase+=1}

    # --- Github
    $feeds[:github][:events].each do |project, repo|
      EM.add_timer(phase) do
        $log.info "Registering Github handler for \"#{project}\" at \"#{repo[:endpoint]}\""
        EM.add_periodic_timer(60, &Handler::Github.handler($log, exchange, $feeds[:github][:token], repo[:endpoint]))
      end
      shift_phase.call
    end


    # --- Disqus
    EM.add_timer(phase) do
      $log.info "Registering Disqus"
      EM.add_periodic_timer(15, &Handler::Disqus.handler($log, exchange, $feeds[:disqus][:api_key]))
    end
    shift_phase.call


    # --- Forums
    forum_endpoints = {
      questions: 'https://forum.javascriptmvc.com/feed/filter/questions',
      all: 'https://forum.javascriptmvc.com/feed'
    }

    EM.add_timer(phase) do
      $log.info "Registering Forums"
      EM.add_periodic_timer(30, &Handler::Forums.handler($log, exchange, forum_endpoints))
    end
    shift_phase.call


    # --- Blog
    EM.add_timer(phase) do
      $log.info "Registering Blog"
      EM.add_periodic_timer(300, &Handler::Blog.handler($log, exchange))
    end
    shift_phase.call


    # --- Old community site
    EM.add_timer(phase) do
      $log.info "Registering Community site"
      EM.add_periodic_timer(300, &Handler::CommunitySite.handler($log, exchange))
    end
    shift_phase.call
  end
end
