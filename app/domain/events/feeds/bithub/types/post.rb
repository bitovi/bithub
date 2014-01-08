module Events
  module Bithub

    class Post
      include Constructable

      def content_digest
      end

      def title
        source_data.andand[:title]
      end

      def url
        source_data.andand[:url]
      end

      def body
        Sanitize.clean(source_data.andand[:body], Sanitize::Config::RELAXED),
      end
    end

  end
end

# extracted: {
#   title: original_hash['title'],
#   url: original_hash['url'],
#   body: Sanitize.clean(original_hash['body'], Sanitize::Config::RELAXED),
# },
