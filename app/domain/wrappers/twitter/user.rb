module Wrappers
  module Twitter

    class User
      extend DataAccessible
      include CoreHelpers

      has :id, :screen_name, :profile_image_url

      def initialize(user)
        @data = symbolize_keys(user)
      end

    end
  end
end
