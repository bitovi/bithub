module Entities
  module Blog

    class Post
      include Entities::Constructable

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        if @payload.url && (entity = find_by_url.first)
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
          url: @payload.link,
          body: @payload.body,
        })
      end

      # Finders
      def find_by_url
        @persistor.where(url: @payload.url)
      end

      def relationships
        Entities::Blog::Post::Relationships
      end
    end

  end
end
