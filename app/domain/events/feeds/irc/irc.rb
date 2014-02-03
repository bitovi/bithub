require_relative 'types/message'

module Events
  module Irc
    class Message < Protocol; end

    def self.type(source_data)
      Events::Irc::Message
    end

    class Processor
      def initialize(response)
        @response = response
      end

      def parse
        #@parsed ||= foo
      end

      def extract
      end

      def decorate
      end
    end
    
  end
end
