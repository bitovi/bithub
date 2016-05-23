require 'wrappers/data_accessible'

module Wrappers
  module Twitter

    class Bits
      include DataAccessible
      include CoreHelpers

      maybe_has :urls, :symbols, :user_mentions, :hashtags

      def initialize(bits)
        @data = symbolize_keys(bits)
      end

      def media
        @data[:media] || []
      end

    end
  end
end
