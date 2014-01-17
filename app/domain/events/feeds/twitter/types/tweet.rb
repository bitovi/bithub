module Events
  module Twitter

    class Status
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

      def origin_timestamp
        Time.parse(source_data.andand[:created_at]).utc
      end

      def html_url
        "https://twitter.com/#{origin_author_name}/status/#{origin_id_str}"
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
