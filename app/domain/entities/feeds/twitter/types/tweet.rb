module Entities
  module Twitter

    class Tweet < Protocol
      
      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def find
        @payload.tweet_id && find_by_tweet_id.first
      end

      def build
        e = Entity.new({
          title: @payload.text,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          origin_id: @payload.tweet_id_str,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            retweeted_id: @payload.original_tweet_id_str,
            entities_urls: ActiveSupport::JSON.encode(@payload.entities_urls),
            origin_author_avatar_url: @payload.user_profile_image_url,
          }
        })
        e[:props][:retweeted_id] = @payload.original_tweet_id if @payload.retweet?
        e
      end
      
      def find_parent
        @payload.original_tweet_id && find_original_tweet.first
      end

      def find_children
        @payload.tweet_id && find_retweets.all
      end

      # Finders
      def find_by_tweet_id
        Entity
        .feed('twitter')
        .type('tweet')
        .where(origin_id: @payload.tweet_id_str)
      end
      
      def find_original_tweet
        Entity
        .feed('twitter')
        .type('tweet')
        .where(origin_id: @payload.original_tweet_id_str)
      end

      def find_retweets
        Entity
        .feed('twitter')
        .type('tweet')
        .where("props -> 'retweeted_id' = '#{@payload.tweet_id_str}'")
      end
    end

  end
end
