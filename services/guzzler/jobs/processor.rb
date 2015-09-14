require 'util'

module Guzzler
  class Processor

    include Util
    include Celluloid

    attr_accessor :proxy_id

    def initialize(boss)
      @manager = boss
    end

    def process(work)
      puts "---------> #{work}"
      # msgstr = work.message
      # queue = work.queue_name

      # @boss.async.real_thread(proxy_id, Thread.current)

      # ack = true
      # begin
      #   msg = Sidekiq.load_json(msgstr)
      #   klass  = msg['class'].constantize
      #   worker = klass.new
      #   worker.jid = msg['jid']

      #   stats(worker, msg, queue) do
      #     Sidekiq.server_middleware.invoke(worker, msg, queue) do
      #       execute_job(worker, cloned(msg['args']))
      #     end
      #   end
      # rescue Sidekiq::Shutdown
      #   # Had to force kill this job because it didn't finish
      #   # within the timeout.  Don't acknowledge the work since
      #   # we didn't properly finish it.
      #   ack = false
      # rescue Exception => ex
      #   handle_exception(ex, msg || { :message => msgstr })
      #   raise
      # ensure
      #   work.acknowledge if ack
      # end

      @manager.async.processor_done(current_actor)
    end

    def inspect
      "<Processor##{object_id.to_s(16)}>"
    end

    private

    def thread_identity
      @str ||= Thread.current.object_id.to_s(36)
    end
  end
end

