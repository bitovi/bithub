module Entities
  module Tumblr

    class Post < Protocol
      def find
        @event.id && find_by_tumblr_id.first
      end

      def find_by_tumblr_id
        Entity
          .feed('tumblr')
          .where(origin_id: @event.id)
      end
    end

    # all these are basically subtypes of Tumblr Post
    # class Answer < Post; end
    # class Audio < Post; end
    # class Chat < Post; end
    # class Link < Post; end
    class Photo < Post; end
    # class Quote < Post; end
    class Text < Post; end
    class Video < Post; end
  end
end

# require_relative 'types/answer'
# require_relative 'types/audio'
# require_relative 'types/chat'
# require_relative 'types/link'
require_relative 'types/photo'
# require_relative 'types/quote'
require_relative 'types/text'
require_relative 'types/video'
