module Guzzler

  class Worker
    include Util
    include Celluloid
    
    def initialize(boss)
      @manager = boss
    end
    attr_accessor :proxy_id

    def inspect
      "<#{self.class.name}##{object_id.to_s(16)}>"
    end

    def shutdown
      Guzzler.logger.info "Shutting down worker in thread #{thread_identity}" if (ENV['ENV'] == 'development' && ENV['DEBUG'])
      terminate
    end

    private

    def thread_identity
      @str ||= Thread.current.object_id.to_s(36)
    end

  end
end
