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

      def origin_timestamp
        Time.at(source_data.andand[:created]).utc
      end
      
    end
  end
end
