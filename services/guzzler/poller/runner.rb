require 'celluloid/current'

require 'manager'
require 'retriever'

require 'processor'
require 'rangey_ren'

module Guzzler
  module Poller

    class Runner
      include Celluloid
      include Util

      def initialize
        @condvar = Celluloid::Condition.new

        @manager = Manager.new_link(Processor, @condvar)
        @retriever = Retriever.new_link(RangeyRen.new('services:polling'), { interval: 5 })

        @retriever.manager = @manager
        @manager.retriever = @retriever

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
end
