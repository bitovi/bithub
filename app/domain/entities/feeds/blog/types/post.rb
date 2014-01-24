module Entities
  module Blog

    class Post < Protocol

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def find
        @payload.link && find_by_url.first
      end

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
