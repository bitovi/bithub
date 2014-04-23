module Entities
  module Twitter

    class Tweet < Protocol
      
      def find
        @event.id && find_by_tweet_id.first
      end

      def build
        built = Entity.new({
          title: @event.text,
          url: @event.html_url,
          origin_ts: @event.created_at,
          origin_id: @event.id_str,
          props: {
            origin_author_id: @event.user.id,
            origin_author_name: @event.user.screen_name,
            origin_author_avatar_url: @event.user.profile_image_url,
            retweeted_id: @event.retweet.id_str,
            entities_urls: ActiveSupport::JSON.encode(@event.entities.urls),
          }
        })
        built[:props][:retweeted_id] = @event.original_tweet_id if @event.retweet?
        built
      end
      
      def find_parent
        @event.retweet.id_str && find_original_tweet.first
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
