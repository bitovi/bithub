module Events
  module Twitter

    class Tweet
      include Constructable

      def content_digest
        Digest::MD5.hexdigest(origin_id.to_s + self.class.name)
      end

      def origin_id
        source_data.andand[:id]
      end
      
      def text
        source_data.andand[:text]
      end

      def user
        source_data.andand[:user]
      end

      def origin_author_id
        user.andand[:id]
      end

      def origin_author_name
        user.andand[:screen_name]
      end

      def html_url
        "https://twitter.com/#{origin_author_name}/status/#{origin_id_str}",
      end

      def retweeted_status
        source_data.andand[:retweeted_status]
      end

      def original_tweet_id
        retweeted_status.andand[:id]
      end
      
      def retweet?
        !!retweeted_status
      end
    end

  end
end

# new_data = {
#   extracted: {
#     title: original_hash['text'],
#     # hash_key: Digest::MD5.hexdigest(original_hash['id_str'] + @feed.to_s),
#     url: "https://twitter.com/#{original_hash['user']['screen_name']}/status/#{original_hash['id_str']}",
#   },
#   meta: {
#     type: 'status_event',
#     origin_author_name: original_hash['user']['screen_name'],
#     origin_author_id: original_hash['user']['id'],
#     origin_id: original_hash['id'],
#     tweet_id: original_hash['id_str'],
#   }
# }

# # add original tweet id -> used later for grouping retweets
# attrs[:meta][:retweeted_id] = original_hash['retweeted_status']['id_str'] if original_hash['retweeted_status']
# processed.deep_merge(new_data)
