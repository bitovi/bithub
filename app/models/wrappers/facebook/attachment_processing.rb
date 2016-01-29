module Wrappers
  module Facebook
    module AttachmentProcessing

      # Objects with 'media' attribute can be nested inside:
      # - attachments['data'][{ 'media' => ... }]
      # - attachments['data'][{ subattachments['data'][{ 'media' => ... }] }, ... ]
      def images
        if data = @data[:attachments].andand[:data]
          extract_from_attachments_by_type(data, types: ['photo', 'share', 'cover_photo'])\
            .map do |p|
            {
              url: p[:media][:image][:src]
            }
          end
        else
          []
        end
      end

      def extract_from_attachments_by_type(data, opts={})
        types = opts[:types] || nil

        data.reduce([]) do |acc, el|
          if types && types.include?(el[:type])
            acc.push el
          elsif sa_data = el[:subattachments].andand[:data]
            # handle subattachments
            acc.push *extract_from_attachments_by_type(sa_data, opts)
          end

          acc
        end
      end
    end
  end
end
