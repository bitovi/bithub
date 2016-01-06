require 'util'

module Guzzler
  class Popper
    include Util
    include Celluloid

    TIMEOUT = 1

    def initialize(q_name, handler_klass)
      @done = false
      @q_name = q_name
      @handler = handler_klass.new(self)
    end

    def start
      Guzzler.logger.info "Starting '#{@q_name}' popper"
      async.fetch
    end

    def stop
      watchdog('Popper#stop died') do
      Guzzler.logger.info { "Terminating '#{@q_name}' popper" }
        @done = true
        terminate
      end
    end

    def fetch
      watchdog('Popper#fetch died') do
        return if stopped?

        begin
          _, item = retrieve_item
          if item 
            @handler.handle(item)
          else
            after(0.001) { fetch }
          end
        rescue => ex
          raise ex
          # handle_fetch_exception(ex)
        end
      end
    end

    def ready
      fetch
    end

    def retrieve_item
      Guzzler.redis { |conn| conn.brpop(@q_name, TIMEOUT) }
    end

    def stopped?
      @done
    end
  end
end

