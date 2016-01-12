require 'celluloid/current'
require 'celluloid/autostart'


require 'guzzler/service'
require 'guzzler/popper'
require 'guzzler/persistor/handlers/event_handler'
require 'guzzler/persistor/handlers/entity_handler'
require 'guzzler/persistor/handlers/error_handler'

module Guzzler
  class Persistor
    include Celluloid
    include Util

    def initialize
      @condvar = Celluloid::Condition.new

      @poppers = []
      @poppers << Popper.new_link('event_q', Handlers::EventHandler)
      @poppers << Popper.new_link('error_q', Handlers::ErrorHandler)
      @poppers << Popper.new_link('entity_q', Handlers::EntityHandler)
      @done = false
    end

    def run
      watchdog('Persistor#run') do
        @poppers.each { |p| p.start }
      end
    end

    def stop
      watchdog('Persistor#run') do
        @done = true
        @poppers.each { |p| p.stop }
      end
    end
  end
end
