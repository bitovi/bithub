require 'wrappers/data_accessible'
require 'wrappers/facebook/attachment_processing'

module Wrappers
  module Facebook

    class Link
      include DataAccessible
      include CoreHelpers
      include AttachmentProcessing

      has :id, :type, :picture, :link
      maybe_has :message, :description

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
