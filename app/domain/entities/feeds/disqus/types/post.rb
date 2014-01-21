module Entities
  module Disqus

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
        @instance = (@payload.post_id && (e = find_by_post_id.first)) ? e : build
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
          body: @payload.message,
          url: @payload.url,
        })
        e.props.symbolize_keys!
        e
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
