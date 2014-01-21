module Entities
  module Forum

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
        if @payload.link && (entity = find_by_url.first)
          @instance = entity
          @instance.props.symbolize_keys! # hstore!
        else
          @instace = build
        end
        
        self
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
        @instance = @persistor.new({
          title: @payload.title,
          body: @payload.body,
          url: @payload.link,
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            tags: [@payload.subforum],
            feed: @payload.feed,
            type: @payload.type,
            origin_author_name: @payload.origin_author_name,
          }
        })
        self
      end

      # Finders
      def find_by_url
        @persistor.tagged_with('forum')
          .where(:url => @payload.link)
      end

      def find_by_thread_prefix
        thread_url, _ = @payload.link.split('#')
        @persistor.tagged_with(%w(forum post))
          .where("url LIKE '#{thread_url}%'")
          .where("#{@persistor.table_name}.id <> #{@instance.id || 'NULL'}")
      end

      def relationships
        Entities::Forum::Post::Relationships
      end
    end

  end
end
