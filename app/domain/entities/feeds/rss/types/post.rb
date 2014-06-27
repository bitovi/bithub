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
          origin_ts: @event.published || Time.now.utc,
        })
      end

      # Finders
      def find_by_link
        Entity.feed('blog').type('post').where(url: @event.link)
      end

      def taggify_by_url
        if name = match_site_by_url(source_url)['name']
          [ name.snake_case ]
        else
          []
        end
      end

      private

      def match_site_by_url(url)
        feed_config
          .fetch('sites')
          .select {|s| s.fetch('url') == url}
          .first
      end

      def sites
        feed_config.fetch('sites')
      end

      def feed_config
        Brand
          .where(name: brand_name).first
          .feed_configs
          .where(feed_name: feed_name).first
          .config
      end

      def meta
        @event.meta
      end

      def brand_name
        meta.fetch(:brand_name)
      end

      def source_url
        meta.fetch(:source_url)
      end

      def feed_name
        'rss'
      end

    end

  end
end
