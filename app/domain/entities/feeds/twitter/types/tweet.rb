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
          thread_updated_ts: @payload.origin_ts,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            tweet_id: @payload.tweet_id,
            retweeted_id: @payload.original_tweet_id
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
        Entity.tagged_with(['twitter', 'tweet'])
        .where("props -> 'tweet_id' = '#{@payload.tweet_id}'")
      end
      
      def find_original_tweet
        Entity.tagged_with(['twitter', 'tweet'])
        .where("props -> 'tweet_id' = '#{@payload.original_tweet_id}'")
      end

      def find_retweets
        Entity.tagged_with(['twitter', 'tweet'])
        .where("props -> 'retweeted_id' = '#{@payload.tweet_id}'")
      end
    end

  end
end
