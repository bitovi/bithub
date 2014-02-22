module Wrappers
  module Twitter

    class Entities
      extend DataAccessible
      include CoreHelpers

      data_accessors :urls, :symbols, :hashtags, :user_mentions

      def initialize(entities)
        @data = symbolize_keys(entities)
      end

    end
  end
end
