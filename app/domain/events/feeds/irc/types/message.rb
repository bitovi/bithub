module Events
  module Irc
    class Message < Protocol

      def title
        message
      end

      def message
        source_data.andand[:message]
      end

      def url
        "http://webchat.freenode.net/?channels=#{channel}"
      end

      def origin_author_name
        nickname
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

      def content_digest
        calc_digest(channel + origin_author_name + origin_ts.to_s)
      end
      
    end
  end
end
