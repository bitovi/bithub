require 'wrappers/data_accessible'

module Wrappers
  module Twitter

    class Entities
      include DataAccessible
      include CoreHelpers

      maybe_has :urls, :symbols, :hashtags, :user_mentions

      def initialize(entities)
        @data = symbolize_keys(entities)
      end

    end
  end
end
