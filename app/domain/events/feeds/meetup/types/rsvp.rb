module Events
  module Meetup

    class Rsvp < Protocol

      def digest_seed
        rsvp_id.to_s + self.class.name
      end

      def origin_id
        rsvp_id
      end

      def rsvp_id
        source_data.andand[:rsvp_id]
      end

      def comment
        source_data.andand[:comments]
      end

      def member
        source_data.andand[:member]
      end

      def member_id
        member.andand[:member_id]
      end
      
      def member_name
        member.andand[:name]
      end

      def member_photo_thumb_link
        source_data.andand[:member_photo].andand[:thumb_link]
      end

      def response
        source_data.andand[:response]
      end

      def parent_event
        source_data.andand[:event]
      end

      def parent_event_id
        parent_event.andand[:id]
      end
      
      def parent_event_url
        parent_event.andand[:url]
      end

      def origin_timestamp
        unix_epoch = source_data.andand[:created].to_i / 1000
        Time.at(unix_epoch).utc
      end
      
      alias_method :origin_author_id, :member_id
      alias_method :origin_author_name, :member_name
      alias_method :origin_author_avatar_url, :member_photo_thumb_link
    end
  end
end
