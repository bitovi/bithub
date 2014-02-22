module Wrappers
  module Disqus

    class Forum
      include CoreHelpers

      def initialize(forum)
        @f = symbolize_keys(forum)
      end

      def id
        @f.andand[:id]
      end

      def name
        @f.andand[:name]
      end

      def url
        @f.andand[:url]
      end
      
    end
  end
end
