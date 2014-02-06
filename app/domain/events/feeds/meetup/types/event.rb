module Events
  module Meetup

    class Event < Protocol

      def origin_id
        source_data.andand[:id]
      end
      
      def event_id
        origin_id.to_s
      end

      def name
        source_data.andand[:name]
      end

      def description
        source_data.andand[:description]
      end

      def url
        source_data.andand[:event_url]
      end

      def status
        source_data.andand[:status]
      end
      
      def scheduled_at
        Time.at(source_data.andand[:time]).utc
      end
      
      def origin_author_id
        source_data.andand[:event_hosts]
        .andand.first.andand[:member_id]
      end

      def origin_author_name
        source_data.andand[:event_hosts]
        .andand.first.andand[:member_name]
      end

      def origin_timestamp
        Time.at(source_data.andand[:created]).utc
      end
    end
  end
end
