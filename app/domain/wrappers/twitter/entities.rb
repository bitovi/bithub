module Wrappers
  module Twitter

    class Entities
      include CoreHelpers

      def initialize(entities)
        @es = symbolize_keys(entities)
      end

      def raw
        @es
      end

      def urls
        @es[:urls]
      end

      def symbols
        @es[:symbols]
      end

      def hashtags
        @es[:hashtags]
      end

      def user_mentions
        @es[:user_mentions]
      end

    end
  end
end
