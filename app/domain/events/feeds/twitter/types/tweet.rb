module Events
  module Twitter

    class Tweet < Protocol
      extend Forwardable

      def_delegator :@user, :id, :origin_author_id
      def_delegator :@user, :screen_name, :origin_author_name
      def_delegator :@user, :profile_image_url, :origin_author_avatar_url

      def_delegators :@tweet, :id, :id_str, :text, :entities, :retweet?

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
        @user ||= Wrappers::Tweet::User.new(source_data.andand[:user])
        @tweet ||= Wrappers::Twitter::Tweet.new(source_data)
      end

    end

  end
end
