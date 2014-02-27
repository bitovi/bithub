module Wrappers
  module StackExchange

    class User
      include DataAccessible
      include CoreHelpers

      has :user_id,
        :display_name,
        :link,
        :reputation,
        :profile_image

      alias_method :name, :display_name

      def initialize(user)
        @data = symbolize_keys(user)
      end

    end
  end
end
