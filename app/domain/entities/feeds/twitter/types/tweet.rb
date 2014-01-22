module Entities
  module Twitter

    class Tweet < Protocol
      
      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        @instance = (@payload.tweet_id && (e = find_by_tweet_id)) ? e : build
        self
      end

      def procure_parent
        find_original_tweet if @payload.original_tweet_id
      end

      def procure_children
        find_retweets.all if @payload.tweet_id
      end

      def procure_references
      end

      # Builder
      def build
        e = Entity.new({
          title: @payload.text,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            feed: @payload.feed,
            type: @payload.type,
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            tweet_id: @payload.tweet_id,
            retweeted_id: @payload.original_tweet_id
          }
        })

        e[:props][:retweeted_id] = @payload.original_tweet_id if @payload.retweet?
        e.props.symbolize_keys!
        e
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
