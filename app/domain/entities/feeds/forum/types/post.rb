module Entities
  module Forum

    class Post
      include Entities::Constructable

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        if @payload.link && (entity = find_by_url.first)
          entity
        else
          build
        end
      end

      def procure_parent
        if @payload.link
          find_by_thread_prefix.order("origin_ts ASC").first
        end
      end

      def procure_children
        if @payload.link
          find_by_thread_prefix.where("origin_ts > ?", @payload.origin_ts).all
        end
      end

      def procure_references
      end

      # Builder
      def build
        @persistor.new({
          title: @payload.title,
          body: @payload.body,
          url: @payload.link,
          props: {
            origin_author_name: @payload.origin_author_name,
            tags: [@payload.subforum],
          }
        })
      end

      # Finders
      def find_by_url
        @persistor.tagged_with('forum')
        .where(:url => @payload.link)
      end

      def find_by_thread_prefix
        thread_url, _ = @payload.url.split('#')
        @persistor.tagged_with(%w(forum post))
        .where("url LIKE '#{thread_url}%'")
      end

      def relationships
        Entities::Forum::Post::Relationships
      end
    end

  end
end
