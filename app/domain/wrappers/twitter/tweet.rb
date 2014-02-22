module Wrappers
  module Twitter

    class Tweet
      include CoreHelpers

      attr_reader :retweet, :entities

      def initialize(tweet)
        @t = symbolize_keys(tweet)
        @entities = Wrappers::Twitter::Entities.new(tweet.andand[:entities])
        if @t[:retweeted_status]
          @retweet = Wrappers::Twitter::Tweet.new(source_data[:retweeted_status])
        end
      end

      def raw
        @t
      end

      def id
        @t.andand[:id]
      end
      
      def id_str
        @t.andand[:id_str]
      end

      def text
        @t.andand[:text]
      end

      def retweet?
        not(@retweet.nil?)
      end

      def created_at
        Time.parse(@t.andand[:created_at])
      end

    end
  end
end
