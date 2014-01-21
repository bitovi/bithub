module Entities
  module Blog

    class Post
      include Entities::Constructable
      include Entities::Determinable

      attr_reader :instance

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        @instance = (@payload.link && (e = find_by_url.first)) ? e : build
        self
      end

      def procure_parent
      end

      def procure_children
      end

      def procure_references
      end

      # Builder
      def build
        e = Entity.new({
          title: @payload.title,
          url: @payload.link,
          body: Sanitize.clean(@payload.body, Sanitize::Config::RELAXED),
        })
        e.props.symbolize_keys!
        e
      end

      # Finders
      def find_by_url
        Entity.tagged_with(%w(blog post))
        .where(url: @payload.link)
      end

      def relationships
        Entity::Blog::Post::Relationships
      end
    end

  end
end
