module Entities
  module Twitter

    module SharedBuilders
            
      def author_meta_attribute
        { searchable_author: @event.user.name + ' ' + @event.user.screen_name }
      end

      def origin_author_data
        {
          props: {
            origin_author_id: @event.user.id,
            origin_author_name: @event.user.screen_name,
          }
        }
      end

      def with_commons(data)
        data
          .merge(author_meta_attribute)
          .deep_merge(origin_author_data)
      end
    end

    class Tweet < Protocol; end
    class Follow < Protocol; end
  end
end

require_relative 'types/tweet'
require_relative 'types/follow'
