module Wrappers
  module Disqus

    class Author
      include CoreHelpers

      def initialize(author)
        @a = symbolize_keys(author)
      end
      
      def id
        @a.andand[:id]
      end

      def name
        @a.andand[:name]
      end

      def username
        @a.andand[:username]
      end

    end
  end
end
