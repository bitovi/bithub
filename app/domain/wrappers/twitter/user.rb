module Wrappers
  module Twitter

    class User
      extend DataAccessible
      include CoreHelpers

      data_accessors :id, :screen_name, :profile_image_url

      def initialize(user)
        @data = symbolize_keys(user)
      end

    end
  end
end
