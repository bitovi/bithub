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

# Logging
log = Log4r::Logger.new('Crawler')
log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

log.info "Loading feeds for #{ENV['ENV']}"

if ENV['ENV'] == 'prod'
  feeds = YAML::load_file('config/feeds.yml')
elsif ENV['ENV'] == 'staging'
  feeds = YAML::load_file('config/feeds_staging.yml')
elsif ENV['ENV'] == 'development'
  feeds = YAML::load_file('config/feeds_dev.yml')
end
    
gh_http_req_head = { "Authorization" => "token #{feeds[:github][:token]}", "Accept" => "application/vnd.github.v3+json" }

# Event loop
AMQP.start(mq_cs) do |connection, open_ok|
  puts "Connected to AMQP broker on #{connection.settings[:host]}:#{connection.settings[:port]}"

  stop = proc { puts "Terminating crawler"; connection.close { EM.stop } }
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(connection)

  channel.fanout("e.events.preproc") do |preproc_exchange|

    # # --- Public stream
    # log.info "Registering to Twitter's public stream"
    # TwitterListener.connect(log, preproc_exchange, feeds[:twitter][:streams][:public_feed], false)

    # # --- User streams
    # feeds[:twitter][:streams][:user_feeds].each do |screen_name, data|
    #   log.info "Registering @#{screen_name} user stream"
    #   TwitterListener.connect(log, preproc_exchange, data, true)
    # end

    # --- Pollers
    phase = 1; shift_phase = lambda {phase+=1}

    # --- Github events endpoint
    feeds[:github][:repos].each do |project, repo|
      if repo[:events]
        EM.add_timer(phase) do
          log.info "Registering Github events handler for \"#{project}\" at \"#{repo[:events]}\""
          EM.add_periodic_timer(3, &Poller.handler(log, preproc_exchange, repo[:events]){|h| h.http_head = gh_http_req_head})
        end
      end
      shift_phase.call
    end

    # # --- Forums
    # feeds[:forums][:endpoints].each do |name, uri|
    #   EM.add_timer(phase) do
    #     log.info "Registering Forums events handler for \"#{name}\" at \"#{uri}\""
    #     EM.add_periodic_timer(120, &Handler::Forums.handler(log, preproc_exchange, uri))
    #   end
    #   shift_phase.call
    # end

    # # --- Disqus
    # EM.add_timer(phase) do
    #   log.info "Registering Disqus"
    #   disqus_uri = feeds[:disqus][:uri].gsub(':api_key', feeds[:disqus][:api_key])
    #   EM.add_periodic_timer(30, &Handler.new(log, preproc_exchange, disqus_uri).handler)
    # end
    # shift_phase.call

    # # --- Blog
    # EM.add_timer(phase) do
    #   log.info "Registering Blog"
    #   EM.add_periodic_timer(600, &Handler::Blog.handler(log, preproc_exchange))
    # end
    # shift_phase.call
  end

  channel.fanout("e.issues") do |issues_exchange|
    queue = channel.queue("q.issues.web").bind(issues_exchange)

    # --- Pollers
    phase = 1; shift_phase = lambda {phase+=1}

    # --- Github issues endpoint
    feeds[:github][:repos].each do |project, repo|
      if repo[:issues]
        log.info "Registering Github issues handler for \"#{project}\" at \"#{repo[:issues]}\""
        EM.add_periodic_timer(5, &Poller.handler(log, issues_exchange, repo[:issues]) {|h| h.http_head = gh_http_req_head})
      end
      shift_phase.call
    end
  end

end
