module Entities
  module Twitter

    class Tweet < Protocol
      include Twitter::SharedBuilders

      def find
        @event.id && find_by_tweet_id.first
      end

      def data
        prepared = {
          title: @event.text,
          url: @event.html_url,
          origin_ts: @event.created_at,
          origin_id: @event.id_str,
          props: {
            origin_author_username: @event.user.screen_name,
            origin_author_avatar_url: @event.user.profile_image_url,
            entities_urls: JSON.generate(@event.entities.urls),
            entities_media: JSON.generate(@event.entities.media)
          }
        }

        prepared[:props][:retweeted_id] = @event.retweet.id if @event.retweet?
        with_commons(prepared)
      end

      def build
        Entity.new(data)
      end

      def find_parent
        (@event.retweet.id_str && find_original_tweet.first) if @event.retweet?
      end

      def find_children
        @event.id_str && find_retweets.all
      end

      # Finders
      def find_by_tweet_id
        Entity
        .feed('twitter')
        .type('tweet')
        .where(origin_id: @event.id_str)
      end

      def find_original_tweet
        Entity
        .feed('twitter')
        .type('tweet')
        .where(origin_id: @event.retweet.id_str)
      end

      def find_retweets
        Entity
        .feed('twitter')
        .type('tweet')
        .where("props -> 'retweeted_id' = '#{@event.id_str}'")
      end
    end

  end
end
