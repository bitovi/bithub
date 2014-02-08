module Entities
  module Irc

    class Message < Protocol

      def find
        nil
      end
      
      def build
        Entity.new({
          title: @payload.title,
          url: @payload.url,
          origin_ts: @payload.origin_ts,
          props: {
            origin_author_name: @payload.origin_author_name
          }
        })
      end
    end
    
  end  
end
