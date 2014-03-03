module Entities
  module Irc

    class Message < Protocol

      def find
        nil
      end
      
      def build
        Entity.new({
          title: @event.title,
          url: @event.url,
          origin_ts: @event.origin_ts,
          props: {
            origin_author_name: @event.nickname,
          }
        })
      end
    end
    
  end  
end
