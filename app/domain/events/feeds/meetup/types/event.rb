module Events
  module Meetup

    class Event < Protocol

      def digest_seed
        event_id + url + name + description + status + composite_location + latitude + longitude + event_host_ids_csv
      end

      def origin_id
        url
      end
      
      def event_id
        source_data.andand[:id].to_s
      end
      
      def url
        source_data.andand[:event_url].to_s
      end

      def name
        source_data.andand[:name]
      end

      def description
        source_data.andand[:description]
      end

      def status
        source_data.andand[:status]
      end
      
      def time
        unix_epoch = source_data.andand[:time].to_i / 1000
        Time.at(unix_epoch).utc
      end

      def scheduled_at
        time.iso8601
      end
      
      def event_hosts
        source_data.andand[:event_hosts] || []
      end

      def event_host_ids_csv
        event_hosts.map{|h| h.andand[:member_id]}.compact.join(',')
      end

      def origin_timestamp
        unix_epoch = source_data.andand[:created].to_i / 1000
        Time.at(unix_epoch).utc
      end

      def venue
        @venue ||= Accessors::Venue.new(source_data.andand[:venue])
      end

      def composite_location
        "#{venue.name}, #{venue.address}, #{venue.city}, #{venue.country}"
      end

      def latitude
        venue.lat
      end

      def longitude
        venue.lon
      end

      alias_method :event_url, :url

    end
  end
end
