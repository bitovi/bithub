module Entities
  module Irc

    class Message < Protocol

      def find
        nil
      end

      def build
        Entity.new({
          title: @event.title,
          url: @event.url,
          origin_ts: @event.origin_ts,
          props: {
            origin_author_name: @event.nickname,
          }
        })
      end

      def taggify_by_url
        if tags = match_chat_by_server_and_channel(server, channel)['tags']
          tags.map {|t| t.snake_case}
        else
          []
        end
      end

      private

      def match_chat_by_server_and_channel(server, channel)
        service_config
          .fetch('chats')
          .select {|c| c.fetch('server') == server and c.fetch('channel') == channel}
          .first
      end

      def service_config
        Brand
          .where(name: brand_name).first
          .services
          .where(feed_name: feed_name, type_name: 'channel').first
          .config
          .data
      end

      def brand_name
        @event.meta.fetch(:brand_name)
      end

      def feed_name
        'irc'
      end

      def server
        @event.meta.fetch(:server)
      end

      def channel
        @event.meta.fetch(:channel)
      end

    end

  end
end
