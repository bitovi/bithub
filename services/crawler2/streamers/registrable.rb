module Streamers
  module Registrable

    def register(channel)
      Celluloid.logger.info "Registering new channel #{channel.name} with topics #{channel.topics}"
      if @channels.select{|c| c.name == channel.name}.empty?
        @channels << channel
        connect
      end
    end

    def unregister(channel)
      Celluloid.logger.info "Un-registering new channel #{channel.name}"
      if @channels.reject!{|c| c.name == channel.name}
        connect
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
