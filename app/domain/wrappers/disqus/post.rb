module Wrappers
  module Disqus

    class Post
      extend DataAccessible
      include CoreHelpers

      has :id, :url, :message
      attr_reader :author, :forum, :thread

      def initialize(post)
        @data = symbolize_keys(post)
        @author = Wrappers::Disqus::Author.new(post.andand[:author])
        @thread = Wrappers::Disqus::Thread.new(post.andand[:thread])
        @forum = Wrappers::Disqus::Forum.new(post.andand[:forum])
      end

      # Disqus provides date in format: "2013-02-14T22:47:29",
      # we append 'Z' to designate that the date is in UTC.
      # (Disqus API docs say so)
      def created_at
        @created_at ||= Time.parse(@data.fetch(:createdAt)+'Z')
      end

      def created_at_utc
        created_at.utc
      end

    end
  end
end
