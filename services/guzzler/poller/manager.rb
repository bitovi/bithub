require 'util'
require 'processor'

module Guzzler
  module Jobs

    class Manager
      include Celluloid
      include Util

      SPIN_TIME_FOR_GRACEFUL_SHUTDOWN = 1

      trap_exit :processor_died

      def initialize(condvar)
        @finished = condvar
        @done = false
        
        @in_progress = {}
        @threads = {}
        @busy = []
        @ready = 5.times.map do
          Processor.new_link(current_actor)
        end
      end
      attr_accessor :fetcher

      def stop
        watchdog('Manager#stop died') do
          @done = true

          Guzzler.logger.info { "Terminating #{@ready.size} quiet processors" }
          @ready.each { |x| x.terminate if x.alive? }
          @ready.clear

          clean_up_for_graceful_shutdown
        end
      end

      def start
        @ready.each { dispatch }
      end

      def dispatch
        return if stopped?
        @fetcher.async.fetch
      end

      def assign(work)
        watchdog("Manager#assign died") do
          processor = @ready.pop
          @in_progress[processor.object_id] = work
          @busy << processor
          processor.async.process(work)
        end
      end

      def processor_done(processor)
        watchdog('Manager#processor_done died') do
          @in_progress.delete(processor.object_id)
          @threads.delete(processor.object_id)
          @busy.delete(processor)
          if stopped?
            processor.terminate if processor.alive?
            shutdown if @busy.empty?
          else
            @ready << processor if processor.alive?
          end
          dispatch
        end
      end

      def processor_died(processor, reason)
        watchdog("Manager#processor_died died") do
          @in_progress.delete(processor)
          @threads.delete(processor)
          @busy.delete(processor)

          if !stopped?
            @ready << Processor.new_link(current_actor)
            dispatch
          else
            shutdown if @busy.empty?
          end
        end
      end

      def clean_up_for_graceful_shutdown
        Guzzler.logger.info "Waiting for processors to finish ..."
        if @busy.empty?
          shutdown
          true
        else
          after(SPIN_TIME_FOR_GRACEFUL_SHUTDOWN) { clean_up_for_graceful_shutdown }
          false
        end
      end

      def stopped?
        @done
      end

      def shutdown
        Guzzler.logger.info "All processors done. Shutting down..."
        @finished.signal
      end

    end
  end
end
