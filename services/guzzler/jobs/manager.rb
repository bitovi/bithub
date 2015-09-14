require 'util'
require 'jobs/processor'

module Guzzler
  class Manager
    include Celluloid
    include Util

    def initialize
      @in_progress = {}
      @threads = {}
      @done = false
      @busy = []
      @ready = 3.times.map do
        Processor.new_link(current_actor)
      end
    end
    attr_accessor :fetcher

    def stop(options={})
      watchdog('Manager#stop died') do
        should_shutdown = options[:shutdown]
        timeout = options[:timeout]

        @done = true

        logger.info { "Terminating #{@ready.size} quiet processors" }
        @ready.each { |x| x.terminate if x.alive? }
        @ready.clear

        return if clean_up_for_graceful_shutdown

        hard_shutdown_in timeout if should_shutdown
      end
    end

    def start
      @ready.each { dispatch }
    end

    def dispatch
      return if stopped?
      @fetcher.async.fetch
    end

    def clean_up_for_graceful_shutdown
      if @busy.empty?
        shutdown
        return true
      end

      after(SPIN_TIME_FOR_GRACEFUL_SHUTDOWN) { clean_up_for_graceful_shutdown }
      false
    end

    def assign(work)
      watchdog("Manager#assign died") do
        if stopped?
          work.requeue
        else
          processor = @ready.pop
          @in_progress[processor.object_id] = work
          @busy << processor
          processor.async.process(work)
        end
      end
    end

    def processor_done(processor)
      watchdog('Manager#processor_done died') do
        @done_callback.call(processor) if @done_callback
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

    def stopped?
      @done
    end

  end
end
