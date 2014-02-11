module Events
  module Bithub
    class Event < Protocol
      include PostLike

      def content_digest
        calc_digest(
          title.to_s + 
          project.to_s + 
          category.to_s + 
          body.to_s +
          image.to_s +
          location.to_s +
          url.to_s +
          origin_author_id.to_s +
          tags.sort.join(',') +
          scheduled_for.to_s +
          origin_author_id.to_s
        )
      end

      def location
        source_data.andand[:location]
      end

    end
  end
end
