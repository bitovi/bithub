require 'celluloid/current'
require 'celluloid/autostart'

require 'jobs/manager'
require 'jobs/fetcher'
require 'jobs/manager'

module Guzzler
  class Launcher
    include Celluloid
    include Util

    def initialize
      @manager = Guzzler::Manager.new_link
      @fetcher = Guzzler::Fetcher.new_link
      @fetcher.manager = @manager
      @manager.fetcher = @fetcher
      @done = false
    end

    def run
      watchdog('Launcher#run') do
        @manager.async.start
      end
    end

  end
end
