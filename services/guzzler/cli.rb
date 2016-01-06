require 'singleton'
require 'json'

require 'guzzler'
require 'util'

module Guzzler

  class CLI
    include Singleton

    def run(klass, file)
      self_read, self_write = IO.pipe
      
      %w(INT TERM USR1 USR2 TTIN).each do |sig|
        begin
          trap sig do
            self_write.puts(sig)
          end
        rescue ArgumentError
          puts "Signal #{sig} not supported"
        end
      end

      Guzzler.redis do |conn|
        # touch the connection pool so it is created before we
        # launch the actors.
      end

      require file
      @launcher = klass.constantize.new

      begin
        @launcher.run

        while readable_io = IO.select([self_read])
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue Interrupt
        Guzzler.logger.info "Shutting down #{klass}"
        @launcher.stop
        exit(0) # Explicitly exit so busy Processor threads can't block process shutdown.
      end
      sleep
    end

    def handle_signal(sig)
      Guzzler.logger.debug "Got #{sig} signal"

      case sig
      when 'INT'
        # Handle Ctrl-C in JRuby like MRI
        # http://jira.codehaus.org/browse/JRUBY-4637
        raise Interrupt
      when 'TERM'
        # Heroku sends TERM and then waits 10 seconds for process to exit.
        raise Interrupt
      # when 'USR1'
      #   logger.info "Received USR1, no longer accepting new work"
      #   launcher.manager.async.stop
      #   fire_event(:quiet, true)
      # when 'USR2'
      #   if Sidekiq.options[:logfile]
      #     Sidekiq.logger.info "Received USR2, reopening log file"
      #     Sidekiq::Logging.reopen_logs
      #   end
      # when 'TTIN'
      #   Thread.list.each do |thread|
      #     Sidekiq.logger.warn "Thread TID-#{thread.object_id.to_s(36)} #{thread['label']}"
      #     if thread.backtrace
      #       Sidekiq.logger.warn thread.backtrace.join("\n")
      #     else
      #       Sidekiq.logger.warn "<no backtrace available>"
      #     end
      #   end
      end
    end
    
  end
end
