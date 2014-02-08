require 'sanitizer'

module Events
  module Forum

    class Post < Protocol

      def content_digest
        calc_digest(link)
      end

      def title
        source_data.andand[:title]
      end

      def body
        source_data.andand[:description]
      end

      def sanitized_body
        sanitize(body)
      end

      def url
        link
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

      def term
        meta.andand[:term]
      end

      def origin_ts
        Time.parse(source_data.andand[:pubDate]).utc
      end

      private

      def sanitize(input)
        (@sanitizer ||= Sanitizer.new).sanitize_forum_post(input)
      end

    end

  end
end
