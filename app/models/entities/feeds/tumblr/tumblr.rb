module Entities
  module Tumblr

    module SharedBuilders

      def url
        { url: @event.link }
      end

      def origin_id_and_ts
        { origin_id: @event.id, origin_ts: @event.created_at }
      end

      def props_tags
        { props: { tags: @event.tags } }
      end
        
      def author_meta_attribute
        { author: @event.blog_name }
      end

      def props_author_data
        { props: { origin_author_name: @event.blog_name } }
      end

      def with_commons(data)
        data.merge(url)
          .merge(origin_id_and_ts)
          .merge(author_meta_attribute)
          .deep_merge(props_tags)
          .deep_merge(props_author_data)
      end
    end

    class Post < Protocol; end
    class Photo < Post; end
    class Text < Post; end
    class Video < Post; end
  end
end

require_relative 'types/post'
require_relative 'types/photo'
require_relative 'types/text'
require_relative 'types/video'

# all these are basically subtypes of Tumblr Post
# but we don't handle them currently
#   class Answer < Post; end
#   class Audio < Post; end
#   class Chat < Post; end
#   class Link < Post; end
