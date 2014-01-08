module Entities
  module Disqus

    class Post
      include Entities::Constructable

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        if @payload.post_id && (entity = find_by_post_id.first)
          entity
        else
          build
        end
      end

      def procure_parent
      end

      def procure_children
      end

      def procure_references
      end

      # Builder
      def build
        Hash.new({
          title: @payload.title,
          body: @payload.message,
          url: @payload.url,
        })
      end

      # Finders
      def find_by_post_id
        @persistor.tagged_with('disqus')
        .where("props -> 'post_id' = '#{@payload.post_id}'")
      end

      def relationships
        Entities::Disqus::Post::Relationships
      end
    end

  end
end
