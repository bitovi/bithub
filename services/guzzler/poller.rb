require 'celluloid/current'
require 'celluloid/autostart'

require 'jobs/manager'
require 'jobs/fetcher'
require 'jobs/manager'

module Guzzler
  class Poller
    include Celluloid
    include Util

    def initialize
      @condvar = Celluloid::Condition.new
      
      @manager = Jobs::Manager.new_link(@condvar)
      @fetcher = Jobs::Fetcher.new_link

      @fetcher.manager = @manager
      @manager.fetcher = @fetcher

      @done = false
    end

    def run
      watchdog('Poller#run') do
        @manager.async.start
      end
    end

    def stop
      watchdog('Poller#stop') do
        @done = true

        @manager.async.stop
        @condvar.wait
        @manager.terminate
        
        @fetcher.terminate if @fetcher.alive?
      end
    end
  end
end
