module Events
  module Irc
    class MessageEvent < Protocol

      def digest_seed
        channel + nickname +  message + origin_ts.to_s + self.class.name
      end

      def message
        source_data.andand[:message]
      end

      def url
        "http://webchat.freenode.net/?channels=#{channel}"
      end

      def nickname
        source_data.andand[:nickname]
      end

      def origin_ts
        source_data.andand[:ts]
      end

      def channel
        source_data.andand[:channel]
      end

      def origin_id
        origin_ts.to_i
      end

      def title
        message
      end
    end
  end
end
