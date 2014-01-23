module Entities
  module Forum

    class Post < Protocol
      
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
        if @payload.link
          find_by_thread_prefix.order("origin_ts ASC").first
        end
      end

      def procure_children
        if @payload.link
          find_by_thread_prefix.where("origin_ts > ?", @payload.origin_ts).all
        end
      end

      # Builder
      def build
        Entity.new({
          title: @payload.title,
          body: @payload.body,
          url: @payload.link,
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            tags: [@payload.subforum] + [@payload.term],
            origin_author_name: @payload.origin_author_name,
          }
        })
      end

      # Finders
      def find_by_url
        Entity.tagged_with(%w(forum post))
          .where(:url => @payload.link)
      end

      def find_by_thread_prefix
        thread_url, _ = @payload.link.split('#')
        Entity.tagged_with(%w(forum post))
          .where("url LIKE '#{thread_url}%'")
          .where("#{Entity.table_name}.id <> #{@instance.id || 'NULL'}")
      end

      def relationships
        Entities::Forum::Post::Relationships
      end
    end

  end
end
