module Wrappers
  module StackExchange

    class User
      extend DataAccessible
      include CoreHelpers

      has :user_id,
        :reputation,
        :profile_image,
        :link,
        :display_name

      def initialize(user)
        @data = symbolize_keys(user)
      end

    end
  end
end
