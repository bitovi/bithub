module Wrappers
  module StackExchange

    class Comment
      include DataAccessible
      include CoreHelpers

      has :comment_id, :post_id, :post_type,
        :body, :link, :score,
        :edited, :body_markdown

      alias_method :edited?, :edited

      attr_reader :user

      def initialize(comment)
        @data = symbolize_keys(comment)
      end

      def creation_date
        Time.at(@data.fetch(:creation_date)).utc
      end

    end

  end
end
