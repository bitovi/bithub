module Entities
  module Blog

    class Post < Protocol

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        @instance = (@payload.link && (e = find_by_url.first)) ? e : build
        self
      end

      # Builder
      def build
        Entity.new({
          title: @payload.title,
          url: @payload.link,
          body: Sanitize.clean(@payload.body, Sanitize::Config::RELAXED),
        })
      end

      # Finders
      def find_by_url
        Entity.tagged_with(%w(blog post))
        .where(url: @payload.link)
      end

      def relationships
        Entity::Blog::Post::Relationships
      end
    end

  end
end
