module Entities
  module Tumblr

    class Photo < Post
      include SharedBuilders

      def data
        with_commons({
          title: @event.source_data[:caption],
          props: {
            photos: JSON.generate(@event.source_data[:photos]),
          }
        })
      end
    end
  end
end
