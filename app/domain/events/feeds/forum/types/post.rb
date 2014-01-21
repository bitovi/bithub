require 'lib/sanitizer'

module Events
  module Forum

    class Post
      include Constructable
      include Persistable

      def content_digest
        calc_digest(link)
      end

      def title
        source_data.andand[:title]
      end

      def body
        source_data.andand[:description]
      end

      def link
        source_data.andand[:link]
      end

      def origin_author_name
        source_data.andand[:'dc:creator']
      end
      
      def subforum
        source_data.andand[:category]
      end

      def origin_ts
        Time.parse(source_data.andand[:pubDate]).utc
      end

      private
      def sanitize(txt)
        (@sanitizer ||= Sanitizer.new).sanitize(txt)
      end
    end

  end
end
