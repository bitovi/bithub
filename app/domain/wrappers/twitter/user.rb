module Wrappers
  module Twitter

    class User
      include CoreHelpers

      def initialize(user)
        @u = symbolize_keys(user)
      end

      def raw
        @u
      end

      def id
        @u.andand[:id]
      end

      def screen_name
        @u.andand[:screen_name]
      end

      def profile_image_url
        @u.andand[:profile_image_url]
      end

    end
  end
end
