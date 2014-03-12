require 'wrappers/data_accessible'

module Wrappers
  module Github

    class Comment
      include DataAccessible
      include CoreHelpers

      has :id, :body, :html_url
      maybe_has :commit_id

      attr_reader :user

      def initialize(comment)
        @data = symbolize_keys(comment)
        @user = Wrappers::Github::User.new(comment[:user])
      end
      
      def created_at
        Time.parse(@data.fetch(:created_at)).utc
      end

      def updated_at
        Time.parse(@data.fetch(:updated_at)).utc
      end

      def references_to
        Reference.scan_for_refs(body)
      end
    end

  end
end
