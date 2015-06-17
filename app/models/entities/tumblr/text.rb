require_relative 'post'

module Entities
  module Tumblr

    class Text < Post

      def data
        with_commons({
          title: @event.source_data[:title] || "undefined",
          body: @event.source_data[:body],
        })
      end

    end
  end
end
