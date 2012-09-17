$: << File.dirname(__FILE__)

require 'bundler/setup'
require 'debugger'

require 'log4r'

require 'yajl'
require 'nokogiri'
require 'nori'

require 'em-http-request'
require 'httparty'

require 'zlib'
require 'base64'

require 'handler'

include EM

##
## Setup
##

#HttpRequest.use Middleware::JSONResponse

@log = Log4r::Logger.new('crawler')
@log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# A few blocking calls to get things started
# @latest_github = HTTParty.get('http://localhost:4567/events/github/latest')
# @latest_forums = HTTParty.get('http://localhost:4567/events/github/latest')
# @latest_blog = HTTParty.get('http://localhost:4567/events/blog/latest')

##
## Crawler
##

EM.run do
  stop = proc { puts "Terminating crawler"; EM.stop }

  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  @log.info "Registering Github"
  EM.add_periodic_timer(5, &Handler::Github.handler(@log))

  @log.info "Registering Disqus"
  EM.add_periodic_timer(10, &Handler::Disqus.handler(@log))

  @log.info "Registering Forums"
  EM.add_periodic_timer(15, &Handler::Forums.handler(@log))

  @log.info "Registering Blog"
  EM.add_periodic_timer(20, &Handler::Blog.handler(@log))
end
