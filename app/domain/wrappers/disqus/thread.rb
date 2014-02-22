module Wrappers
  module Disqus

    class Thread
      include CoreHelpers

      def initialize(author)
        @t = symbolize_keys(author)
      end
      
      def id
        @t.andand[:id]
      end

      def title
        @t.andand[:title]
      end

      def link
        @t.andand[:link]
      end

      # Disqus provides date in format: "2013-02-14T22:47:29",
      # we append 'Z' to designate that the date is in UTC.
      # (Disqus API docs say so)
      def created_at
        @created_at ||= Time.parse(@t.andand[:createdAt]+'Z')
      end

    end
  end
end
