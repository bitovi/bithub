require_relative 'post'

module Bits
  module Tumblr

    class Video < Post

      def data
        with_commons({
          title: @event.source_data[:caption],
          body: @event.source_data[:player].last[:hub_code],
        })
      end

    end
  end
end
