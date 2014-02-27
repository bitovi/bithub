module Wrappers
  module Disqus

    class Forum
      include DataAccessible
      include CoreHelpers

      has :id, :name, :url

      def initialize(forum)
        @data = symbolize_keys(forum)
      end

    end
  end
end
