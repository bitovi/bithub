require 'wrappers/data_accessible'

module Wrappers
  module Twitter

    class Tweet
      include DataAccessible
      include CoreHelpers

      attr_reader :retweet, :entities
      has :id, :id_str, :text

      def initialize(tweet)
        @data = symbolize_keys(tweet)
        @entities = Wrappers::Twitter::Entities.new(tweet.andand[:entities])
        if @data[:retweeted_status]
          @retweet = Wrappers::Twitter::Tweet.new(@data[:retweeted_status])
        end
      end

      def retweet?
        not(@retweet.nil?)
      end

      def created_at
        Time.parse(@data.andand[:created_at]).utc
      end

      alias_method :retweeted_status, :retweet

    end
  end
end
