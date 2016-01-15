require 'util'

module Guzzler

  class Retriever
    include Util
    include Celluloid

    TIMEOUT = 1

    def initialize(strategy, opts = {})
      @strategy = strategy
      @interval = opts[:interval] || 1
    end
    attr_accessor :manager

    def retrieve
      watchdog("Retriever#retrieve died") do
        return if stopped?

        begin
          if item = @strategy.retrieve
            @manager.async.assign(item)
          else
            after(@interval) { retrieve }
          end
        rescue => ex
          raise ex
          handle_retrieve_exception(ex)
        end
      end
    end

    def handle_retrieve_exception(ex)
      Guzzler.logger.error "Error fetching message: #{ex}"
      pause
      after(0) { retreive }
    end

    def pause
      sleep(TIMEOUT)
    end

    def stopped?
      @done
    end
  end
end
