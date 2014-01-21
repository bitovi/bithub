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
require 'ostruct'

# Ours
require 'lib/core_ext'
require 'lib/loggable'
require 'lib/configurable'
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

def transform_head(head)
  head.reduce({}) do |acc, (k, v)|
    acc.merge({k.capitalize => v})
  end
end

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

    # # --- Twitter public stream
    # logger.info "Registering Twitter - public tweets stream"
    # pub_stream_conn_opts = feeds[:twitter][:public][:streaming]
    # Streamer.connect(events_exchange, pub_stream_conn_opts) do |config|
    #   config.is_user_stream = false
    # end

    # # --- Twitter user streams
    # feeds[:twitter][:user_streams].each do |screen_name, user_stream_conn_opts|
    #   logger.info "Registering Twitter - @#{screen_name} user events stream"
    #   Streamer.connect(events_exchange, user_stream_conn_opts) do |config|
    #     config.is_user_stream = true
    #   end
    # end

    # # --- Meetup open events stream
    # stream_conn_opts = feeds[:meetup][:open_events][:streaming]
    # logger.info "Registering Meetup - open events stream"
    # Streamer.connect(events_exchange, stream_conn_opts) do |config|
    # end

    # ---------------
    # --- Pollers ---
    # ---------------

    # --- Github
    feeds[:github][:repos].each do |repo_name, repo_config|

      if repo_config[:events]
        log_registering(repo_config[:events])
        EM.add_periodic_timer(
          intervals[:github][:events],
          &Poller.handler(events_exchange, repo_config[:events]) do |config|
            config.http_head = transform_head(feeds[:github][:head])
          end
        )
      end

      if repo_config[:issues]
        [:open, :closed].each do |state|
          log_registering(repo_config[:issues], {state: state})
          EM.add_periodic_timer(
            intervals[:github][:issues][state],
            &Poller.handler(events_exchange, repo_config[:issues]) do |config|
              config.http_head = transform_head(feeds[:github][:head])
              config.http_query = { state: state, per_page: 100 }
              config.backlog_size = 1000
            end
          )
        end
      end
    end
    
    
    # --- Meetup open events
    feed_config = feeds[:meetup][:open_events][:polling]
    log_registering(feed_config[:url])
    EM.add_periodic_timer(
      intervals[:meetup],
      &Poller.handler(events_exchange, feed_config[:url]) do |c|
        c.http_query = feed_config[:query]
      end
    )


    # --- Twitter statuses
    feed_config = feeds[:twitter][:public][:polling]
    log_registering(feed_config[:url])
    EM.add_periodic_timer(
      intervals[:twitter],
      &Poller.handler(events_exchange, feed_config[:url]) do |c|
        c.http_query = feed_config[:query]
      end
    )


    # --- Forums general feed
    log_registering(feeds[:forum][:general][:url])
    EM.add_periodic_timer(
      intervals[:forum],
      &Poller.handler(events_exchange, feeds[:forum][:general][:url])
    )
    

    # --- Forums questions feed
    log_registering(feeds[:forum][:questions][:url])
    EM.add_periodic_timer(
      intervals[:forum],
      &Poller.handler(events_exchange, feeds[:forum][:questions][:url]) do |config|
        config.processor_tips = { tags: ['question'] }
      end
    )


    # --- Disqus
    feed_config = feeds[:disqus][:posts]
    log_registering(feed_config[:url])
    EM.add_periodic_timer(
      intervals[:disqus],
      &Poller.handler(events_exchange, feed_config[:url]) do |config|
        config.http_query = feed_config[:query]
      end
    )


    # --- Blog
    log_registering(feeds[:blog][:url])
    EM.add_periodic_timer(
      intervals[:blog],
      &Poller.handler(events_exchange, feeds[:blog][:url])
    )

    # ----------------
    # --- No more! ---
    # ----------------
  end
end
