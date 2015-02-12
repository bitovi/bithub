require 'wrappers/data_accessible'

module Wrappers
  module Twitter

    class Entities
      include DataAccessible
      include CoreHelpers

      maybe_has :urls, :symbols, :user_mentions, :hashtags

      def initialize(entities)
        @data = symbolize_keys(entities)
      end

      def media
        @data[:media] || []
      end

    end
  end
end
