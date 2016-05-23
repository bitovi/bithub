require 'bits/protocol'
require_relative 'shared'

module Bits
  module Twitter

    class Tweet < Protocol
      include Shared

      def find
        @event.id && find_by_tweet_id.first
      end

      def data
        prepared = {
          title: @event.text,
          url: @event.html_url,
          origin_ts: @event.created_at,
          origin_id: @event.id_str,
          popularity: @event.retweet_count + @event.favorite_count,
          props: {
            origin_author_avatar_url: @event.user.profile_image_url,
            entities_urls: JSON.generate(@event.bits.urls),
            entities_media: JSON.generate(@event.bits.media)
          }
        }

        prepared[:props][:retweeted_id] = @event.retweeted_status.id if @event.retweet?
        prepared[:props][:quoted_id] = @event.quoted_status.id if @event.quote?
        with_commons(prepared)
      end

      def find_parent
        (@event.retweet.id_str && find_original_tweet.first) if @event.retweet?
      end

      def find_children
        @event.id_str && find_retweets.all
      end

      # Finders
      def find_by_tweet_id
        Bit
        .feed('twitter')
        .type('tweet')
        .where(origin_id: @event.id_str)
      end

      def find_original_tweet
        Bit
        .feed('twitter')
        .type('tweet')
        .where(origin_id: @event.retweet.id_str)
      end

      def find_retweets
        Bit
        .feed('twitter')
        .type('tweet')
        .retweeted_id(@event.id_str)
      end
    end

  end
end
