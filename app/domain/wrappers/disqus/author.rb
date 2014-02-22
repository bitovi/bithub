module Wrappers
  module Disqus

    class Author
      extend DataAccessible
      include CoreHelpers

      data_accessors :id, :name, :username

      def initialize(author)
        @data = symbolize_keys(author)
      end
      
    end
  end
end
