module Entities
  module Disqus

    class Post < Protocol

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        @instance = (@payload.post_id && (e = find_by_post_id.first)) ? e : build
        self
      end

      # Builder
      def build
        Entity.new({
          title: @payload.title,
          body: @payload.message,
          url: @payload.url,
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
