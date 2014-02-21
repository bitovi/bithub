module Wrappers
  module Github

    class Actor
      include CoreHelpers

      def initialize(actor)
        @a = symbolize_keys(actor)
      end

      def raw
        @a
      end

      def id
        @a.andand[:id]
      end

      def id_str
        id.to_s
      end

      def login
        @a.andand[:login]
      end

      def gravatar_id
        @a.andand[:gravatar_id]
      end

      def avatar_url
        @a.andand[:avatar_url]
      end

    end

  end
end
