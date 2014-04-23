require 'wrappers/data_accessible'

module Wrappers
  module Facebook

    class Status
      include DataAccessible
      include CoreHelpers

      has :id, :type
      maybe_has :message, :link

      def initialize(status)
        @data = symbolize_keys(status)
      end

      def created_time
        Time.parse(@data.fetch(:created_time)).utc
      end

      def updated_time
        Time.parse(@data.fetch(:updated_time)).utc
      end
    end
  end
end
