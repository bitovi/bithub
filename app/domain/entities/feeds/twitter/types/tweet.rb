module Entities
  module Twitter
    module Tweet

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI

        def find(payload)
          if payload.tweet_id
            find_by_tweet_id(payload.tweet_id)
          end
        end

        def find_parent(payload)
          if payload.retweeted_id
            find_by_tweet_id(payload.retweeted_id).first
          end
        end

        def find_children(payload)
          if payload.tweet_id
            find_by_retweeted_id(payload.tweet_id).all
          end
        end

        def find_by_tweet_id(tweet_id)
          @p.tagged_with(['twitter', 'status_event'])
            .where("props -> 'tweet_id' = '#{tweet_id}'")
        end

        def find_by_retweeted_id(tweet_id)
          @p.tagged_with(['twitter', 'status_event'])
            .where("props -> 'retweeted_id' = '#{tweet_id}'")
        end
      end

    end
  end
end
