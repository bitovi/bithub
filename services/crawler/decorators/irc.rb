module Decorators
  class Irc < Protocol

    def initialize(chat_config)
      @server = chat_config[:server]
      @channel = chat_config[:channel]
    end

    def decorate(event)
      event[:meta][:server] = @server
      event[:meta][:channel] = @channel
      event
    end
  end
end
