module Events
  module Twitter

    class Tweet < Protocol

      def content_digest
        Digest::MD5.hexdigest(origin_id.to_s + self.class.name)
      end

      def origin_id
        tweet_id_str
      end

      def tweet_id
        source_data.andand[:id]
      end

      def tweet_id_str
        source_data.andand[:id_str]
      end

      def text
        source_data.andand[:text]
      end

      def user
        source_data.andand[:user]
      end

      def user_id
        user.andand[:id]
      end

      def user_screen_name
        user.andand[:screen_name]
      end

      def user_profile_image_url
        user.andand[:profile_image_url]
      end

      def origin_timestamp
        Time.parse(source_data.andand[:created_at]).utc
      end

      def html_url
        "https://twitter.com/#{origin_author_name}/status/#{origin_id}"
      end

      def retweeted_status
        source_data.andand[:retweeted_status]
      end

      def retweeted_status_id
        retweeted_status.andand[:id]
      end

      def retweeted_status_id_str
        retweeted_status.andand[:id_str]
      end

      def entities
        source_data.andand[:entities]
      end

      def entities_urls
        entities.andand[:urls]
      end

      def retweet?
        !!retweeted_status
      end

      alias_method :origin_author_id, :user_id
      alias_method :origin_author_name, :user_screen_name
      alias_method :origin_author_avatar_url, :user_profile_image_url
      alias_method :original_tweet_id, :retweeted_status_id
      alias_method :original_tweet_id_str, :retweeted_status_id_str
    end

  end
end
