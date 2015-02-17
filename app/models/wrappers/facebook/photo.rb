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
        extract_images_from_attachments
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

      def extract_images_from_attachments
        subattachments.reduce([]) do |acc, a|
          if img = a[:media].andand[:image]
            acc.push({
              url: img[:src],
              width: img[:width],
              height: img[:height]
            })
          end

          acc
        end
      end

      def subattachments
        @data[:attachments][:data].reduce([]) do |acc, a|
          if data = a[:subattachments].andand[:data]
            acc.push data
          end

          acc
        end.flatten
      end

    end
  end
end
