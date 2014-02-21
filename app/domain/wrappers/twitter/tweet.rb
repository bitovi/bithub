module Wrappers
  module Twitter

    class Tweet
      include CoreHelpers

      def initialize(tweet)
        @t = symbolize_keys(tweet)
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

    end
  end
end
