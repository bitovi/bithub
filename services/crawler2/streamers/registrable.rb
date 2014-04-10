module Streamers
  module Registrable

    def register(channel, reloading: false)
      Celluloid.logger.info "Registering new channel #{channel.name} with topics #{channel.topics}"
      if @channels.select{|c| c.name == channel.name}.empty?
        @channels << channel

        if reloading
          reconnect
        else
          connect
        end
      end

    end

    def unregister(channel_name, reloading: false)
      channel_topics = @channels.detect{|c| c.name == channel_name}.topics
      Celluloid.logger.info "Un-registering channel #{channel_name} with #{channel_topics}"

      if @channels.reject!{|c| c.name == channel_name}
        reconnect unless reloading
      end
    end

    def route(object, attrs)
      @channels.each do |c|
        publish(c.name, object) if c.interested?(object, attrs)
      end
    end

    def publish(brand, object)
      Celluloid::Actor[:publisher].publish(brand, [object])
    end
  end
end
