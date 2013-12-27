module Entities
  module Twitter
    module Tweet

      Relationships = {
        upstream: [Entities::Twitter::Tweet],
        downstream: []
      }

      class Procurer < Entities::Procurer

        def find(payload)
          if tweet_id(payload)
            find_by_tweet_id(issue_id(payload))
          end
        end

        def build(payload)
          if type(payload) == 'Issue'
            build_from_issue
          else
            fail Entities::Errors::BuildingException, "don't know how to build an entity from supplied payload"
          end
        end

        def find_by_tweet_id(tweet_id)
          @p.tagged_with(['twitter','status_event'])
            .where("props -> 'tweet_id' = '#{tweet_id}'")
        end

        def find_by_retweeted_id(tweet_id)
          @p.tagged_with(['twitter','status_event'])
            .where("props -> 'retweet_id' = '#{tweet_id}'")
        end
        
        def build_from_tweet(payload)
        end
        
        def build_from_retweet(payload)
        end
      end

    end
  end
end

# module Grouping
#   class Twitter

#     def initialize
#     end

#     def group_twitter    
#       if tweet?
#         if retweet?
#           group_retweet
#         else
#           group_tweet
#         end
#       end
#       self
#     end

#     def group_tweet
#       if rts = my_retweets
#         self.children += (rts + rts.collect{|rt| rt.children}.flatten).uniq
#       end
#       self
#     end

#     def group_retweet
#       if ot = original_tweet
#         self.parent = ot
#       elsif frrt = first_related_retweet
#         self.parent = frrt
#       end
#       self
#     end

#     def tweet?
#       tag_list.include?('twitter') and tag_list.include?('status_event')
#     end

#     def retweet?
#       !!props[:retweeted_id]
#     end

#     def my_retweets
#       Event.tweets_by_retweeted_id(props[:tweet_id]).all
#     end

#     def original_tweet
#       Event.tweets_by_tweet_id(props[:retweeted_id]).first
#     end

#     def first_related_retweet
#       Event.tweets_by_retweeted_id(props[:retweeted_id]).order('origin_ts ASC').first
#     end

#   end
# end
