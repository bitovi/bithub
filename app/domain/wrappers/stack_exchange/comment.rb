module Wrappers
  module StackExchange

    class Comment
      extend DataAccessible
      include CoreHelpers

      data_accessors :edited, :score,
        :post_id,
        :comment_id,
        :link, :body,
        :body_markdown

      attr_reader :user

      def initialize(comment)
        @data = symbolize_keys(comment)
        @owner = Wrappers::StackExchange::User.new(@data.andand[:owner])
      end

      def creation_date
        Time.at(@data[:creation_date])
      end

    end

  end
end
