module Events
  module Twitter

    class Tweet < Protocol
      extend Forwardable

      def_delegator :@user, :id, :user_id
      def_delegator :@user, :screen_name, :user_screen_name
      def_delegator :@user, :profile_image_url, :user_profile_image_url

      def_delegators :@tweet, :id, :id_str, :text, :entities, :retweet?

      attr_accessor :retweet

      def digest_seed
        id_str + self.class.name
      end

      def origin_id
        id_str
      end

      def origin_timestamp
        @tweet.created_at.utc
      end

      def html_url
        "https://twitter.com/#{@user.screen_name}/status/#{@tweet.id_str}"
      end
      
      def wrap_reponse_parts
        @user ||= Wrappers::Twitter::User.new(source_data.andand[:user])
        @tweet ||= Wrappers::Twitter::Tweet.new(source_data)
        @retweet ||= @tweet.retweeted_status
      end

      alias_method :origin_author_id, :user_id
      alias_method :origin_author_name, :user_screen_name
      alias_method :origin_author_avatar_url, :user_profile_image_url
    end

  end
end
