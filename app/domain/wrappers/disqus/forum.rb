module Wrappers
  module Disqus

    class Forum
      extend DataAccessible
      include CoreHelpers

      data_accessors :id, :name, :url

      def initialize(forum)
        @data = symbolize_keys(forum)
      end

    end
  end
end
