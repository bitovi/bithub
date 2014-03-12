require 'wrappers/data_accessible'

module Wrappers
  module Disqus

    class Post
      include DataAccessible
      include CoreHelpers

      has :id, :url, :message

      def initialize(post)
        @data = symbolize_keys(post)
      end

      # Disqus provides date in format: "2013-02-14T22:47:29",
      # we append 'Z' to designate that the date is in UTC.
      # (Disqus API docs say so)
      def created_at
        @created_at ||= Time.parse(@data.fetch(:createdAt)+'Z').utc
      end

    end
  end
end
