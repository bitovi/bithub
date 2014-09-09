module Events
  module Bithub
    class PostEvent < Protocol
      include PostLike

      def content_digest
        calc_digest(
          title.to_s +
          project.to_s +
          category.to_s +
          body.to_s +
          image.to_s +
          url.to_s +
          origin_author_id.to_s +
          tags.sort.join(',') +
          origin_author_id.to_s
        )
      end

      def validate
        self
      end

    end
  end
end
