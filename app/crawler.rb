$: << File.expand_path(File.join(File.dirname(__FILE__), '../'))

# Theirs
require 'bundler/setup'
require 'rubygems'
require 'log4r'
require 'amqp'
require 'yaml'

# Ours
require 'lib/core_ext'
require 'app/poller'
require 'app/listener'

# Connection string
mq_cs = ENV['RABBITMQ_URI']

# paths to config files based on env
config_paths = {
  'prod' => 'config/config.yml',
  'staging' => 'config/config_staging.yml',
  'development' => 'config/config_dev.yml'
}

# Logging
logger = Log4r::Logger.new('Crawler')
logger.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

$logger = logger


# Load config 
logger.info "Loading feeds for #{ENV['ENV']}"
config = YAML::load_file(config_paths[ENV['ENV']])
feeds = config[:feeds]
intervals = config[:intervals]

gh_http_req_head = { "Authorization" => "token #{feeds[:github][:token]}", "Accept" => "application/vnd.github.v3+json" }

def log_registering(endpoint)
  $logger.info "Registering poller at #{endpoint[0..50]}"
end

# Event loop
AMQP.start(mq_cs) do |connection, open_ok|
  puts "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)

  channel.direct("e.events") do |events_exchange|
    queue = channel.queue("q.events").bind(events_exchange)

    # # --- Public stream
    # logger.info "Registering to Twitter's public stream"
    # Listener.connect(logger, events_exchange, feeds[:twitter][:streams][:public_feed], false)

    # # --- User streams
    # feeds[:twitter][:streams][:user_feeds].each do |screen_name, data|
    #   logger.info "Registering @#{screen_name} user stream"
    #   Listener.connect(logger, events_exchange, data, true)
    # end

    # --- Pollers
    phase = 1; shift_phase = lambda {phase+=1}

    # --- Github events endpoint
    feeds[:github][:repos].each do |repo_name, repo_config|
      if repo_config[:events]
        EM.add_timer(phase) do
          log_registering(repo_config[:events])
          EM.add_periodic_timer(intervals[:github][:events], &Poller.handler(logger, events_exchange, repo_config[:events]){|c| c[:http_head] = gh_http_req_head})
        end
      end
      shift_phase.call
    end

    # --- Forums
    feeds[:forums].each do |term, term_uri|
      EM.add_timer(phase) do
        log_registering(term_uri)
        EM.add_periodic_timer(intervals[:forums], &Poller.handler(logger, events_exchange, term_uri){|c| c[:term] = term})
      end
      shift_phase.call
    end

    # --- Disqus
    EM.add_timer(phase) do
      disqus_uri = feeds[:disqus][:uri].gsub(':api_key', feeds[:disqus][:api_key])
      log_registering(disqus_uri)
      EM.add_periodic_timer(intervals[:disqus], &Poller.handler(logger, events_exchange, disqus_uri))
    end
    shift_phase.call

    # --- Blog
    EM.add_timer(phase) do
      log_registering(feeds[:blog])
      EM.add_periodic_timer(intervals[:blog], &Poller.handler(logger, events_exchange, feeds[:blog]))
    end
  end

  channel.direct("e.issues") do |issues_exchange|
    queue = channel.queue("q.issues").bind(issues_exchange)

    # --- Pollers
    phase = 1; shift_phase = lambda {phase+=1}

    # # --- Github issues endpoint
    # feeds[:github][:repos].each do |repo_name, repo_config|
    #   if repo_config[:issues]
    #     ['open', 'closed'].each do |state|
    #       EM.add_timer(phase) do
    #         log_registering(repo_config[:issues])
    #         EM.add_periodic_timer(intervals[:github][:issues], &Poller.handler(logger, events_exchange, repo_config[:events]){|c| c[:http_head] = gh_http_req_head})
    #       end
    #       shift_phase.call
    #     end
    #   end
    # end
  end
end
