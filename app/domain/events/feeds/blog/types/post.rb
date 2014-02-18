module Events
  module Blog
    class Post < Protocol

      def content_digest
        @digest ||= Digest::MD5.hexdigest(link + self.class.name)
      end
      
      def link
        source_data.andand[:link]
      end

      def title
        source_data.andand[:title]
      end

      def description
        Sanitize.clean(source_data.andand[:description], Sanitize::Config::RELAXED)
      end

      def origin_timestamp
        Time.strptime(source_data.andand[:published], "%e %b %Y").utc
      end

      alias_method :body, :description
    end
  end
end
