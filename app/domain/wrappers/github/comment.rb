module Wrappers
  module Github

    class Comment
      extend DataAccessible
      include CoreHelpers

      attr_reader :user
      data_accessors :id, :body, :html_url, :commit_id

      def initialize(comment)
        @data = symbolize_keys(comment)
        @user = Wrappers::Github::User.new(comment.andand[:user])
      end

      def references_to
        Reference.scan_for_refs(body)
      end
    end

  end
end
