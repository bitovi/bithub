require 'util'

module Guzzler
  class Manager
    include Celluloid
    include Util

    SPIN_TIME_FOR_GRACEFUL_SHUTDOWN = 1

    trap_exit :worker_died

    def initialize(worker_class, condvar, opts = {})
      @finished = condvar
      @done = false

      @worker_class = worker_class
      @worker_num = opts[:concurrency] || 5

      @in_progress = {}
      @threads = {}
      @busy = []
      @ready = @worker_num.times.map do
        @worker_class.new_link(current_actor)
      end
    end
    attr_accessor :retriever
    
    def start
      Guzzler.logger.info "Starting manager for #{@worker_class} with #{@worker_num} workers"
      @ready.each { dispatch }
    end

    def stop
      watchdog('Manager#stop died') do
        @done = true

        Guzzler.logger.info { "Terminating #{@ready.size} quiet workers" }
        @ready.each { |x| x.shutdown if x.alive? }
        @ready.clear

        clean_up_for_graceful_shutdown
      end
    end

    def dispatch
      return if stopped?
      @retriever.async.retrieve
    end

    def assign(work)
      watchdog("Manager#assign died") do
        worker = @ready.pop
        @in_progress[worker.object_id] = work
        @busy << worker
        worker.async.process(work)
      end
    end

    def worker_done(worker)
      watchdog('Manager#worker_done died') do
        @in_progress.delete(worker.object_id)
        @threads.delete(worker.object_id)
        @busy.delete(worker)
        if stopped?
          worker.shutdown if worker.alive?
          shutdown if @busy.empty?
        else
          @ready << worker if worker.alive?
        end
        dispatch
      end
    end

    def worker_died(worker, reason)
      watchdog("Manager#worker_died died") do
        @in_progress.delete(worker)
        @threads.delete(worker)
        @busy.delete(worker)

        if !stopped?
          @ready << @worker_class.new_link(current_actor)
          dispatch
        else
          shutdown if @busy.empty?
        end
      end
    end

    def clean_up_for_graceful_shutdown
      Guzzler.logger.info "Waiting for workers to finish ..."
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
      @finished.signal
    end

  end
end
