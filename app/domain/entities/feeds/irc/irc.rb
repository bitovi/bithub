module Entities
  module Irc
    class Message < Protocol; end

    def self.type(arg)
      Entities::Irc::Message
    end
    
  end
end

require_relative 'types/message'
