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
        Entity.feed('rss').type('post').where(url: @event.link)
      end

      def taggify_by_url
        if tags = match_site_by_url(source_url)['tags']
          tags.map {|t| t.snake_case}
        else
          []
        end
      end

      # legacy from forums
      def find_parent
        if @event.link and for_bitovi?
          find_by_thread_prefix.where("origin_ts < ?", @event.published).order("origin_ts ASC").first
        end
      end

      # legacy from forums
      def find_children
        if @event.link and for_bitovi?
          find_by_thread_prefix.where("origin_ts > ?", @event.published).all
        end
      end

      private

      def match_site_by_url(url)
        feed_config
          .fetch('sites')
          .select {|s| s.fetch('url') == url}
          .first
      end

      # legacy from forums
      def find_by_thread_prefix
        thread_url, _ = @event.link.split('#')

        scope = Entity.feed('rss').where("url LIKE '#{thread_url}%'")
        scope = scope.where("#{Entity.table_name}.id <> #{@instance.id}") if @instance.id
        scope
      end

      # legacy from forums
      def for_bitovi?
        @event.link.starts_with? 'http://forum.javascriptmvc.com'
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
