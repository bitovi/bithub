require 'sanitizer'

module Events
  module Forum

    class Post < Protocol

      def content_digest
        calc_digest(link + self.class.name)
      end

      def title
        source_data.andand[:title]
      end

      def description
        source_data.andand[:description]
      end

      def link
        source_data.andand[:link]
      end

      def origin_author_name
        source_data.andand[:'dc:creator']
      end

      def category
        source_data.andand[:category]
      end

      def term
        meta.andand[:term]
      end

      def origin_timestamp
        Time.parse(source_data.andand[:pubDate]).utc
      end

      def sanitized_body
        sanitize(description)
      end

      def sanitize(input)
        (@sanitizer ||= Sanitizer.new).sanitize_forum_post(input)
      end

      alias_method :body, :description
      alias_method :url, :link
      alias_method :subforum, :category
    end

  end
end
