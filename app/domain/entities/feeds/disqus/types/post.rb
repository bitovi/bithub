module Entities
  module Disqus

    class Post < Protocol

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def find
        @payload.post_id && find_by_post_id.first
      end

      def build
        Entity.new({
          title: @payload.title,
          body: @payload.message,
          url: @payload.url,
          origin_ts: @payload.origin_ts,
        })
      end

      # Finders
      def find_by_post_id
        Entity.tagged_with(%w(disqus post))
          .where("props -> 'post_id' = '#{@payload.post_id}'")
      end

      def relationships
        Entities::Disqus::Post::Relationships
      end
    end

  end
end
