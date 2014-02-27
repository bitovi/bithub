module Entities
  module Forum

    class Post < Protocol

      def find
        @event.link && find_by_url.first
      end

      def build
        Entity.new({
          title: @event.title,
          body: @event.description,
          url: @event.link,
          origin_ts: @event.origin_timestamp,
          props: {
            tags: [@event.subforum, @event.term],
            origin_author_name: @event.origin_author_name,
          }
        })
      end

      def find_parent
        if @event.link
          find_by_thread_prefix.where("origin_ts < ?", @event.origin_timestamp).order("origin_ts ASC").first
        end
      end

      def find_children
        if @event.link
          find_by_thread_prefix.where("origin_ts > ?", @event.origin_timestamp).all
        end
      end

      def find_by_url
        Entity.feed('forum').type('post').where(:url => @event.link)
      end

      private
      def find_by_thread_prefix
        thread_url, _ = @event.link.split('#')

        scope = Entity.feed('forum').where("url LIKE '#{thread_url}%'")
        scope = scope.where("#{Entity.table_name}.id <> #{@instance.id}") if @instance.id
        scope
      end
    end

  end
end
