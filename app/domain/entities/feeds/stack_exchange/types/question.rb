module Entities
  module StackExchange

    class Question < Protocol

      def find
        nil
      end

      def build
        Entity.new({
          title: @payload.title,
          url: @payload.link,
          origin_id: @payload.origin_id,
          origin_ts: @payload.origin_ts,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            origin_author_avatar_url: @payload.origin_author_avatar_url,
          }
        })
      end

    end
  end
end
