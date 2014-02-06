ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
DOMAIN_DIR = File.join(ROOT_DIR, 'app', 'domain')
LIB_DIR = File.join(ROOT_DIR, 'lib')
SERVICES_DIR = File.join(ROOT_DIR, 'services')

$:.unshift(DOMAIN_DIR)
$:.unshift(LIB_DIR)
$:.unshift(SERVICES_DIR)

# Theirs
require 'bundler/setup'
require 'rubygems'
require 'log4r'
require 'amqp'
require 'yaml'
require 'ostruct'

# Ours
require 'core_ext'
require 'loggable'
require 'crawler/poller'
require 'crawler/streamer'

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

  channel.direct("e.events") do |ex|
    queue = channel.queue("q.events").bind(ex)

    # ----------------
    # --- Streams ----
    # ----------------

    # # --- Twitter public stream
    # logger.info "Registering Twitter - public tweets stream"
    # pub_stream_conn_opts = feeds[:twitter][:public][:streaming]
    # Streamer.connect(ex, pub_stream_conn_opts) do |config|
    #   config.is_user_stream = false
    # end

    # # --- Twitter user streams
    # feeds[:twitter][:user_streams].each do |screen_name, user_stream_conn_opts|
    #   logger.info "Registering Twitter - @#{screen_name} user events stream"
    #   Streamer.connect(ex, user_stream_conn_opts) do |config|
    #     config.is_user_stream = true
    #   end
    # end

    # # --- Meetup open events stream
    # stream_conn_opts = feeds[:meetup][:open_events][:streaming]
    # logger.info "Registering Meetup - open events stream"
    # Streamer.connect(ex, stream_conn_opts) do |config|
    # end

    # ---------------
    # --- Pollers ---
    # ---------------


    # --- Github
    feeds[:github][:repos].each do |repo_name, repo_config|

      if repo_config[:events]
        log_registering(repo_config[:events])

        EM.add_periodic_timer(intervals[:github][:events], Poller.new(ex, repo_config[:events]) do |c|
          c.http_head = transform_head(feeds[:github][:head])
        end.handler)
      end

      if repo_config[:issues]
        [:open, :closed].each do |state|
          log_registering(repo_config[:issues], {state: state})

          EM.add_periodic_timer(intervals[:github][:issues][state], Poller.new(ex, repo_config[:issues]) do |c|
            c.http_head = transform_head(feeds[:github][:head])
            c.http_query = { state: state, per_page: 100 }
            c.digest_queue_config = { backlog_size: 1000 }
          end.extend(Pageable).handler)
        end
      end
    end
    

    # --- Meetup open events
    feed_config = feeds[:meetup][:open_events][:polling]
    log_registering(feed_config[:url])

    EM.add_periodic_timer(intervals[:meetup], Poller.new(ex, feed_config[:url]) do |c|
      c.http_query = feed_config[:query]
    end.handler)
    
    # --- Meetup rsvps
    feed_config = feeds[:meetup][:rsvps]
    log_registering(feed_config[:url])

    EM.add_periodic_timer(intervals[:meetup], Poller.new(ex, feed_config[:url]) do |c|
      c.http_query = feed_config[:query]
      c.boot_data_url = feed_config[:boot_data_url]
      c.reboot_delay = 10 
    end.extend(Bootable).extend(Bootable::RSVPs).boot.handler)


    # --- Twitter statuses
    feed_config = feeds[:twitter][:public][:polling]
    log_registering(feed_config[:url])
    EM.add_periodic_timer(intervals[:twitter], Poller.new(ex, feed_config[:url]) do |c|
      c.http_query = feed_config[:query]
    end.handler)


    # --- Forums general feed
    log_registering(feeds[:forum][:general][:url])
    EM.add_periodic_timer(intervals[:forum], Poller.new(ex, feeds[:forum][:general][:url]).handler)
    

    # --- Forums questions feed
    log_registering(feeds[:forum][:questions][:url])
    EM.add_periodic_timer(intervals[:forum], Poller.new(ex, feeds[:forum][:questions][:url]) do |c|
      c.processor_config = { term: 'question' }
    end.handler)


    # --- Disqus
    feed_config = feeds[:disqus][:posts]
    log_registering(feed_config[:url])
    EM.add_periodic_timer(intervals[:disqus], Poller.new(ex, feed_config[:url]) do |c|
      c.http_query = feed_config[:query]
    end.handler)


    # --- Blog
    log_registering(feeds[:blog][:url])
    EM.add_periodic_timer(intervals[:blog], Poller.new(ex, feeds[:blog][:url]).handler)

    # ----------------
    # --- No more! ---
    # ----------------
  end
end
