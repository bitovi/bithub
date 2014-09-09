require 'wrappers/data_accessible'

module Wrappers
  module Facebook

    class Comment
      include DataAccessible
      include CoreHelpers
      
      has :id, :message

      def initialize(comment)
        @data = symbolize_keys(comment)
      end

      def poster_id
        @data.fetch(:from).fetch(:id)
      end
      
      def poster_name
        @data.fetch(:from).fetch(:name)
      end

      def created_time
        Time.parse(@data.fetch(:created_time)).utc
      end

    end
  end
end
