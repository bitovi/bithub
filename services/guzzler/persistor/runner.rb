require 'celluloid/current'

require 'service'
require 'manager'
require 'retriever'

require 'event_handler'
require 'error_handler'
require 'entity_handler'
require 'poppity_pop'

module Guzzler
  module Persistor

    class Runner
      include Celluloid
      include Util

      def initialize
        @cvs = []; @mgs = []; @rtrs = []

        @cvs << (@cv1 = Celluloid::Condition.new)
        @cvs << (@cv2 = Celluloid::Condition.new)
        @cvs << (@cv3 = Celluloid::Condition.new)

        @mgs << (@event_manager = Manager.new_link(EventHandler, @cv1, { concurrency: 5 }))
        @rtrs << (@event_retriever = Retriever.new_link(PoppityPop.new('event_q')))
        @event_retriever.manager = @event_manager
        @event_manager.retriever = @event_retriever

        @mgs << (@entity_manager = Manager.new_link(EntityHandler, @cv2, { concurrency: 10 }))
        @rtrs << (@entity_retriever = Retriever.new_link(PoppityPop.new('entity_q')))
        @entity_retriever.manager = @entity_manager
        @entity_manager.retriever = @entity_retriever

        @mgs << (@error_manager = Manager.new_link(ErrorHandler, @cv3, { concurrency: 1 }))
        @rtrs << (@error_retriever = Retriever.new_link(PoppityPop.new('error_q')))
        @error_retriever.manager = @error_manager
        @error_manager.retriever = @error_retriever

        @done = false
      end

      def run
        watchdog('Persistor#run') do
          @mgs.each { |m| m.start }
        end
      end

      def stop
        watchdog('Persistor#run') do
          @done = true

          @mgs.each { |m| m.async.stop }
          @cvs.each { |cv| cv.wait }
          @rtrs.each { |r| r.terminate if r.alive? }
        end
      end
    end
  end
end
