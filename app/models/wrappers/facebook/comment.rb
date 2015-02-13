require 'wrappers/data_accessible'

module Wrappers
  module Facebook

    class Comment
      include DataAccessible
      include CoreHelpers

      has :id, :message

      def initialize(data)
        @data = symbolize_keys(data)
      end

      def from_id
        @data.fetch(:from).fetch(:id)
      end

      def from_name
        @data.fetch(:from).fetch(:name)
      end

      def created_time
        Time.parse(@data.fetch(:created_time)).utc
      end

    end
  end
end
