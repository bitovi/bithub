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
require 'lib/hash'

# Connection string
$mq_cs = ENV['RABBITMQ_URI']

# paths to config files based on env
$config_paths = {
  'prod' => 'config/config.yml',
  'staging' => 'config/config_staging.yml',
  'development' => 'config/config_dev.yml'
}

# Logging
$log = Log4r::Logger.new('crawler')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# Load config 
$log.info "Loading feeds for #{ENV['ENV']}"
$config = YAML::load_file($config_paths[ENV['ENV']])
$feeds = $config[:feeds]
$intervals = $config[:intervals]

# Event loop
AMQP.start($mq_cs) do |connection, open_ok|
  puts "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)

  channel.fanout("e.events.preproc") do |preproc_exchange|

    # --- Public stream
    $log.info "Registering to Twitter's public stream"
    Handler::Twitter.connect($log, preproc_exchange, $feeds[:twitter][:streams][:public_feed], false)

    # --- User streams
    $feeds[:twitter][:streams][:user_feeds].each do |screen_name, data|
      $log.info "Registering @#{screen_name} user stream"
      Handler::Twitter.connect($log, preproc_exchange, data, true)
    end

    # --- Pollers
    phase = 1; shift_phase = lambda {phase+=1}

    # --- Github events endpoint
    $feeds[:github][:repos].each do |project, repo|
      if repo[:events] 
        EM.add_timer(phase) do
          $log.info "Registering Github events handler for \"#{project}\" at \"#{repo[:events]}\""
          # or to make something bold in console log with "\033[1mFOOBAR\033[0m ?!
          EM.add_periodic_timer($intervals[:github][:events], &Handler::Github.handler($log, preproc_exchange, $feeds[:github][:token], repo[:events]))
        end
      end
      shift_phase.call
    end

    # --- Disqus
    EM.add_timer(phase) do
      $log.info "Registering Disqus"
      EM.add_periodic_timer($intervals[:disqus], &Handler::Disqus.handler($log, preproc_exchange, $feeds[:disqus][:api_key]))
    end
    shift_phase.call


    # --- Forums
    forum_endpoints = {
      questions: 'https://forum.javascriptmvc.com/feed/filter/questions',
      all: 'https://forum.javascriptmvc.com/feed'
    }

    EM.add_timer(phase) do
      $log.info "Registering Forums"
      EM.add_periodic_timer($intervals[:forums], &Handler::Forums.handler($log, preproc_exchange, forum_endpoints))
    end
    shift_phase.call


    # --- Blog
    EM.add_timer(phase) do
      $log.info "Registering Blog"
      EM.add_periodic_timer($intervals[:blog], &Handler::Blog.handler($log, preproc_exchange))
    end
    shift_phase.call

  end

  channel.fanout("e.issues") do |issues_exchange|
    queue = channel.queue("q.issues.web").bind(issues_exchange)

    # --- Pollers
    phase = 1; shift_phase = lambda {phase+=1}

    # --- Github issues endpoint
    $feeds[:github][:repos].each do |project, repo|
      if repo[:issues]
        ['open', 'closed'].each do |state|
          EM.add_timer(phase) do
            $log.info "Registering Github #{state} issues handler for \"#{project}\" at \"#{repo[:issues]}\""
            EM.add_periodic_timer($intervals[:github][:issues][state], &Handler::GithubIssues.handler($log, issues_exchange, $feeds[:github][:token], state, repo[:issues]))
          end
          shift_phase.call
        end
      end
    end
    
  end
end
