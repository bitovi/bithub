module Entities
  module Twitter
    class Tweet

      class Procurer < Twitter::Procurer
      end

      module Finders
        def find_tweets_by_tweet_id(tweet_id)
          tagged_with(['twitter','status_event'])
          .where("props -> 'tweet_id' = '#{tweet_id}'")
        end

        def find_tweets_by_retweeted_id(tweet_id)
          tagged_with(['twitter','status_event'])
          .where("props -> 'retweeted_id' = '#{tweet_id}'")
        end
      end

      module Builders

        # TODO
        def build_tweet_from_retweet(attrs)
        end
      end

    end
  end
end
