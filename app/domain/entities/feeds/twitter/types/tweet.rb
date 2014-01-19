module Entities
  module Twitter

    class Tweet
      include Entities::Constructable
      include Entities::Determinable

      attr_reader :instance
      
      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        if @payload.tweet_id && (entity = find_by_tweet_id)
          @instance = entity
          @instance.props.symbolize_keys! # hstore!
        else
          build
        end
        
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
        @instance = @persistor.new({
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

        @instance[:props][:retweeted_id] = @payload.original_tweet_id if @payload.retweet?
        self
      end

      # Finders
      def find_by_tweet_id
        @persistor.tagged_with(['twitter', 'tweet'])
        .where("props -> 'tweet_id' = '#{@payload.tweet_id}'")
        .first
      end
      
      def find_original_tweet
        @persistor.tagged_with(['twitter', 'tweet'])
        .where("props -> 'tweet_id' = '#{@payload.original_tweet_id}'")
        .first
      end

      def find_retweets
        @persistor.tagged_with(['twitter', 'tweet'])
        .where("props -> 'retweeted_id' = '#{@payload.tweet_id}'")
      end

    end

  end
end
