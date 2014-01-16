module Events
  module Meetup

    class Event
      include Constructable

      def origin_id
        # puts "Meetup::Event#origin_id #{@data.inspect}"
        source_data.andand[:id]
      end

      def origin_author_id
      end

      def origin_author_name
        source_data.andand[:author].andand[:name]
      end

      def origin_timestamp
        Time.parse(source_data.andand[:createdAt]+'Z').utc
      end
    end
  end
end
