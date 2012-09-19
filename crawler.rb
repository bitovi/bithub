$: << File.dirname(__FILE__)

# Theirs
require 'bundler/setup'
require 'log4r'
require 'yajl'
require 'nokogiri'
require 'nori'
require 'em-http-request'
require 'httparty'
require 'zlib'
require 'base64'

# Ours
require 'handler'

include EM

def start_crawler
  # Log file config
  log = Log4r::Logger.new('crawler')
  log.add(Log4r::StdoutOutputter.new('console', {
    :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
  }))

  storer_url = YAML.load_file('config/config.yml')[ENV['ENV']]['storer-url']
  EM.run do
    stop = proc { puts "Terminating crawler"; EM.stop }

    Signal.trap("INT",  &stop)
    Signal.trap("TERM", &stop)

    log.info "Registering Github"
    EM.add_periodic_timer(5, &Handler::Github.handler(log, storer_url))

    log.info "Registering Disqus"
    EM.add_periodic_timer(10, &Handler::Disqus.handler(log, storer_url))

    log.info "Registering Forums"
    EM.add_periodic_timer(15, &Handler::Forums.handler(log, storer_url))

    log.info "Registering Blog"
    EM.add_periodic_timer(20, &Handler::Blog.handler(log, storer_url))
  end
end
