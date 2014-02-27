module Wrappers
  module Disqus

    class Author
      include DataAccessible
      include CoreHelpers

      has :name
      maybe_has :id, :username

      def initialize(author)
        @data = symbolize_keys(author)
      end
      
    end
  end
end
