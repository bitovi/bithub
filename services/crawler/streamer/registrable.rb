module Streamers
  module Registrable
    attr_reader :last_registration

    def register(channel, reloading: false)
      Celluloid.logger.info "Registering new channel #{channel.name} with topics #{channel.topics}"
      if channels.select{|c| c.name == channel.name}.empty?
        channels << channel
        timed_connect(reloading)
      end
    end

    def unregister(channel_name, reloading: false)
      channel_topics = channel_with_name(channel_name).andand.topics
      Celluloid.logger.info "Un-registering channel #{channel_name} with #{channel_topics}"

      if channels.reject!{|c| c.name == channel_name}
        reconnect unless reloading
      end
    end

    def route(object, feed, attrs)
      channels.each do |c|
        publish(c.name, feed, object) if c.interested?(object, attrs)
      end
    end

    def publish(brand, feed, object)
      Celluloid::Actor[:publisher].publish brand, feed, [object]
    end

    def channel_with_name(name)
      channels.detect{|c| c.name == name}
    end

    def channels
      @channels ||= Set.new
    end

    def timed_connect(reloading)
      if @last_registration
        @last_registration.reset
      else
        @last_registration = after(registration_timeout) { reconnect }
      end
    end

    def registration_timeout
      $env == 'development' ? 5 : 30
    end

  end
end
