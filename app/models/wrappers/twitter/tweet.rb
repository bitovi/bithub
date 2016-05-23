require 'wrappers/data_accessible'

module Wrappers
  module Twitter

    class Tweet
      include DataAccessible
      include CoreHelpers

      attr_reader :retweeted_status, :quoted_status, :bits
      has :id, :id_str, :text, :retweet_count, :favorite_count

      def initialize(tweet)
        @data = symbolize_keys(tweet)
        @bits = Wrappers::Twitter::Bits.new(tweet.andand[:bits])
        if @data[:retweeted_status]
          @retweeted_status = Wrappers::Twitter::Tweet.new(@data[:retweeted_status])
        elsif @data[:quoted_status]
          @quoted_status = Wrappers::Twitter::Tweet.new(@data[:quoted_status])
        end
      end

      def retweet?
        !@retweeted_status.nil?
      end
      
      def quote?
        !@quoted_status.nil?
      end

      def created_at
        Time.parse(@data.andand[:created_at]).utc
      end

      alias_method :retweet, :retweeted_status
      alias_method :quote, :quoted_status
    end
  end
end
