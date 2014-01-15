module Entities
  module Twitter

    class Tweet
      include Entities::Constructable

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }


      def procure
        if @payload.tweet_id && (entity = find_by_tweet_id)
          entity
        else
          build
        end
      end

      def procure_parent
        find_original_tweet if @payload.retweeted_id
      end

      def procure_children
        find_retweets.all if @payload.tweet_id
      end

      def procure_references
      end

      # Builder
      def build
        entity = @persistor.new({
          title: @payload.text,
          url: @payload.html_url,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            # origin_id: original_hash['id'],
            # tweet_id: original_hash['id_str'],
          }
        })

        entity[:props][:retweeted_id] = @payload.original_tweet_id if @payload.retweet?
        entity
      end

      # Finders
      def find_by_tweet_id
        @persistor.tagged_with(['twitter', 'status_event'])
        .where("props -> 'tweet_id' = '#{@payload.tweet_id}'")
        .first
      end
      
      def find_original_tweet
        @persistor.tagged_with(['twitter', 'status_event'])
        .where("props -> 'tweet_id' = '#{@payload.retweeted_id}'")
        .first
      end

      def find_retweets
        @persistor.tagged_with(['twitter', 'status_event'])
        .where("props -> 'retweeted_id' = '#{@payload.tweet_id}'")
      end

    end

  end
end
