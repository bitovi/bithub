module Events
  module Twitter

    class Tweet < Protocol
      extend Forwardable

      def_delegators :@tweet, :id, :id_str,
        :text, :retweet, :retweeted_status,
        :entities, :retweet?

      attr_accessor :tweet, :user

      def digest_seed
        id_str + self.class.name
      end

      def html_url
        "https://twitter.com/#{@user.screen_name}/status/#{@tweet.id_str}"
      end
      
      def wrap_response
        @tweet ||= Wrappers::Twitter::Tweet.new(source_data)
        @user ||= Wrappers::Twitter::User.new(source_data[:user])
        self
      end
    end

  end
end
