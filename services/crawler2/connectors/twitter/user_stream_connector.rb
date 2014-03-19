require_relative 'client'

module Connectors
  module Twitter

    class TwitterUserStreamConnector
      include Client

      def listen
        @client.user do |object|
          yield object if block_given?
        end
      end
    end

  end
end

# case object
# when Twitter::Tweet
#   puts "It's a tweet!"
# when Twitter::DirectMessage
#   puts "It's a direct message!"
# when Twitter::Streaming::StallWarning
#   warn "Falling behind!"
# end
