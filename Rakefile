$: << File.dirname(__FILE__)

namespace :jobs do
  desc "Start the crawler"
  task :work do

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

    begin

      # Log file config
      @log = Log4r::Logger.new('crawler')
      @log.add(Log4r::StdoutOutputter.new('console', {
        :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
      }))

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

    rescue Exception => e
      puts e.inspect
      e.backtrace.each { |line| puts line }
    end
  end
end
