module Entities
  module Rss

    class Post < Protocol

      def find
        @event.link && find_by_link.first
      end

      def build
        Entity.new({
          title: @event.title,
          body: @event.description,
          url: @event.link,
          origin_ts: @event.pub_date,
        })
      end

      # Finders
      def find_by_link
        Entity.feed('blog').type('post').where(url: @event.link)
      end

    end

  end
end
