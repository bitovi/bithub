module Entities
  module Rss

    class Post < Protocol

      def find
        @event.link && find_by_link.first
      end

      def data
        {
          title: @event.title,
          body: @event.description,
          url: @event.link,
          searchable_author: @event.author,
          origin_ts: @event.published || Time.now.utc,
          props: {
            origin_author_name: @event.author
          }
        }
      end

      # Finders
      def find_by_link
        Entity.feed('rss').type('post').where(url: @event.link)
      end

      def taggify_by_tag_with
        if (t = service_config['tag_with'])
          [t.snake_case]
        else
          []
        end
      end

      private

      def service_config
        Brand
          .where(name: brand_name)
          .first
            .services
            .feed('rss')
            .type('site')
            .first
              .service_config
              .data
      end

      def meta
        @event.meta
      end

      def brand_name
        meta.fetch(:brand_name)
      end
    end
  end
end
