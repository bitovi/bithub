require_relative 'post'

module Entities
  module Tumblr

    class Video < Post

      def data
        with_commons({
          title: @event.source_data[:caption],
          body: @event.source_data[:player].last[:embed_code],
        })
      end

    end
  end
end
