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
        if data = @data[:attachments].andand[:data]
          extract_from_attachments_by_type(data, types: ['photo', 'cover_photo'])\
            .map do |p|
            {
              url: p[:media][:image][:src]
            }
          end
        else
          []
        end
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

      private

      # Objects with 'media' attribute can be nested inside:
      # - attachments['data'][{ 'media' => ... }]
      # - attachments['data'][{ subattachments['data'][{ 'media' => ... }] }, ... ]

      def extract_from_attachments_by_type(data, opts={})
        types = opts[:types] || nil

        data.reduce([]) do |acc, el|

          puts "=== #{el[:type]}, #{types}"
          if types && types.include?(el[:type])
            acc.push el
          elsif sa_data = el[:subattachments].andand[:data]
            # handle subattachments
            acc.push *extract_from_attachments_by_type(sa_data, type)
          end

          acc
        end
      end

    end
  end
end
