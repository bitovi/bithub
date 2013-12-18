module Events
  module Twitter
    module Tweet
      #Relationships = [Entities::Twitter::Tweet]

      class Processor
        def process(original_hash, processed)
          attrs = {
            title: original_hash['text'],
            # hash_key: Digest::MD5.hexdigest(original_hash['id_str'] + @feed.to_s),
            url: "https://twitter.com/#{original_hash['user']['screen_name']}/status/#{original_hash['id_str']}",
            meta: {
              type: 'status_event',
              origin_author_name: original_hash['user']['screen_name'],
              origin_author_id: original_hash['user']['id'],
              origin_id: original_hash['id'],
              tweet_id: original_hash['id_str'],
            }
          }

          # add original tweet id -> used later for grouping retweets
          attrs[:meta][:retweeted_id] = original_hash['retweeted_status']['id_str'] if original_hash['retweeted_status']
          processed.deep_merge(attrs)
        end
      end

    end
  end
end
