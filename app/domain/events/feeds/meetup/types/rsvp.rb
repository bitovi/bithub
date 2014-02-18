module Events
  module Meetup

    class Rsvp < Protocol

      def origin_id
        source_data.andand[:rsvp_id]
      end

      def rsvp_id
        origin_id.to_s
      end

      def comment
        source_data.andand[:comments]
      end

      def member
        source_data.andand[:member]
      end

      def origin_author_id
        member.andand[:member_id]
      end

      def response
        source_data.andand[:response]
      end

      def origin_author_name
        member.andand[:name]
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

      def origin_author_avatar_url
        source_data.andand[:member_photo].andand[:thumb_link]
      end
      
    end
  end
end
