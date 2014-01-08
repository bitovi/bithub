CRAWLER_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
ROOT_DIR = File.expand_path(File.join(CRAWLER_DIR, '..', '..'))
DOMAIN_DIR = File.join(ROOT_DIR, 'app', 'domain')

$:.unshift(ROOT_DIR)
$:.unshift(DOMAIN_DIR)

# Theirs
require 'bundler/setup'
require 'rubygems'
require 'log4r'
require 'amqp'
require 'yaml'

# Ours
require 'lib/core_ext'
require 'services/crawler/poller'
require 'services/crawler/streamer'

# paths to config files based on env
config_path = File.join(ROOT_DIR, 'config', 'services', 'crawler', "#{ENV['ENV']}.yml")

# Logging
logger = Log4r::Logger.new('Crawler')
logger.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

$logger = logger

# Load config 
logger.info "Loading feeds for #{ENV['ENV']}"
config = YAML::load_file(config_path)
feeds = config[:feeds]
intervals = config[:intervals]

gh_http_req_head = {
  "Authorization" => "token #{feeds[:github][:token]}",
  "Accept" => "application/vnd.github.v3+json"
}

def log_registering(endpoint, query = nil)
  str = "Registering poller at #{endpoint}"
  str += " with query #{query}" if query
  $logger.info str
end

# Event loop
AMQP.start(ENV['RABBITMQ_URI']) do |connection, open_ok|
  puts "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)

  channel.direct("e.events") do |events_exchange|
    queue = channel.queue("q.events").bind(events_exchange)

    # ----------------
    # --- Streams ----
    # ----------------

    # # --- Public stream
    # logger.info "Registering to Twitter's public stream"
    # Streamer.connect(logger, events_exchange, feeds[:twitter][:streams][:public_feed], false)

    # # --- User streams
    # feeds[:twitter][:streams][:user_feeds].each do |screen_name, data|
    #   logger.info "Registering @#{screen_name} user stream"
    #   Streamer.connect(logger, events_exchange, data, true)
    # end

    # ---------------
    # --- Pollers ---
    # ---------------

    # # --- Github events
    # feeds[:github][:repos].each do |repo_name, repo_config|
    #   if repo_config[:events]
    #     log_registering(repo_config[:events])
    #     EM.add_periodic_timer(intervals[:github][:events], &Poller.handler(events_exchange, repo_config[:events]) do |c|
    #       c[:http_head] = gh_http_req_head
    #     end)
    #   end
    # end


    # # --- Forums general feed
    # log_registering(feeds[:forums][:general])
    # EM.add_periodic_timer(intervals[:forums], &Poller.handler(events_exchange, feeds[:forums][:general]))


    # # --- Forums by specific terms
    # feeds[:forums][:terms].each do |term, term_uri|
    #   log_registering(term_uri)
    #   EM.add_periodic_timer(intervals[:forums], &Poller.handler(events_exchange, term_uri) do |c|
    #     c[:processor_config] = {term: term}
    #   end)
    # end


    # # --- Disqus
    # log_registering(feeds[:disqus][:uri])
    # EM.add_periodic_timer(intervals[:disqus], &Poller.handler(events_exchange, feeds[:disqus][:uri]) do |c|
    #   c[:http_query] = feeds[:disqus][:query]
    # end)


    # --- Meetup
    log_registering(feeds[:meetup][:uri])
    EM.add_periodic_timer(intervals[:meetup], &Poller.handler(events_exchange, feeds[:meetup][:uri]) do |c|
      c[:http_query] = feeds[:meetup][:query]
    end)


    # # --- Blog
    # log_registering(feeds[:blog])
    # EM.add_periodic_timer(intervals[:blog], &Poller.handler(events_exchange, feeds[:blog]))


    # --- Github issues
    feeds[:github][:repos].each do |repo_name, repo_config|
      if repo_config[:issues]
        [:open, :closed].each do |state|
          EM.add_timer(phase) do
            log_registering(repo_config[:issues], {state: state})
            EM.add_periodic_timer(intervals[:github][:issues][state], &Poller.handler(events_exchange, repo_config[:issues]) do |c|
              c[:http_head] = gh_http_req_head
              c[:http_query] = { state: state, per_page: 100 }
              c[:backlog_size] = 1000
            end)
          end
        end
      end
    end

    # ----------------
    # --- No more! ---
    # ----------------
  end
end
