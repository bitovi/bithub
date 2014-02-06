require_relative 'types/message'

module Events
  module Irc
    class Message < Protocol; end

    def self.type(source_data)
      Events::Irc::Message
    end
  end
end
