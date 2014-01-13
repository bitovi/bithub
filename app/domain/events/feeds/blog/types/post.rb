module Events
  module Blog
    class Post
      include Constructable

      def content_digest
        @digest ||= Digest::MD5.hexdigest(link.to_s + self.class.name)
      end

      def title
        source_data.andand[:title]
      end

      def body
        Sanitize.clean(source_data.andand[:description], Sanitize::Config::RELAXED)
      end

      def link
        source_data.andand[:link]
      end

      def origin_timestamp
        Time.strptime(source_data.andand[:published], "%e %b %Y").utc
      end
    end

  end
end
