module Wrappers
  module Github

    class User
      include CoreHelpers

      def initialize(actor)
        @u = symbolize_keys(actor)
      end

      def raw
        @u
      end

      def id
        @u.andand[:id]
      end

      def id_str
        id.to_s
      end

      def login
        @u.andand[:login]
      end

      def gravatar_id
        @u.andand[:gravatar_id]
      end

      def avatar_url
        @u.andand[:avatar_url]
      end

    end

  end
end
