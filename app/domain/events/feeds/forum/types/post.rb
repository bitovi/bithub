require 'lib/sanitizer'

module Events
  module Forum

    class Post
      include Constructable

      def content_digest
        @digest ||= Digest::MD5.hexdigest(link + self.class.name)
      end

      def title
        source_data.andand[:title]
      end

      def body
        source_data.andand[:description]
      end

      def url
        source_data.andand[:link]
      end

      def origin_author_name
        source_data.andand[:'dc:creator']
      end
      
      def subforum
        source_data.andand[:category]
      end

      def origin_timestamp
        Time.parse(source_data.andand[:pubDate]).utc
      end

      private
      def sanitize(txt)
        (@sanitizer ||= Sanitizer.new).sanitize(txt)
      end
    end

  end
end

# new_data = {
#   extracted: {
#     title: original_hash['title'],
#     body: sanitize(original_hash['description']),
#     url: original_hash['link'],
#   },
#   meta: {
#     feed: 'forum',
#     type: 'post',
#     tags: original_hash['category'].snake_case,
#     origin_author_name: original_hash['dc:creator'],
#   }
# }
