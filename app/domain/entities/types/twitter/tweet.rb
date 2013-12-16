module Entities
  module Twitter
    class Tweet

      def find_tweets_by_tweet_id(tweet_id)
        query = {
          tags: %w(twitter status_event),
          props: { tweet_id: tweet_id }
        }
      end

      def find_tweets_by_retweeted_id(tweet_id)
        query = {
          tags: %w(twitter status_event),
          props: { retweeted_id: tweet_id }
        }
      end

    end
  end
end
