require_relative 'shared'

module Bits
  module Tumblr

    module Shared

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
        { searchable_author: @event.blog_name }
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
  end
end
