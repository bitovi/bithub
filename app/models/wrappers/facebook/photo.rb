require 'wrappers/data_accessible'

module Wrappers
  module Facebook

    class Photo
      include DataAccessible
      include CoreHelpers

      has :id, :type, :picture
      maybe_has :message, :link, :source, :width, :height

      def initialize(status)
        @data = symbolize_keys(status)
      end

      def images
        @data.fetch(:images) { [] }
      end

      def photo_id
        @data.fetch(:object_id)
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
