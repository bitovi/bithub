module Wrappers
  module Disqus

    class Thread
      extend DataAccessible
      include CoreHelpers

      has :id, :title, :link

      def initialize(author)
        @data = symbolize_keys(author)
      end

      # Disqus provides date in format: "2013-02-14T22:47:29",
      # we append 'Z' to designate that the date is in UTC.
      # (Disqus API docs say so)
      def created_at
        @created_at ||= Time.parse(@data.andand[:createdAt]+'Z').utc
      end

    end
  end
end
