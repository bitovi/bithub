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
        unix_epoch = source_data.andand[:time].to_i / 1000
        Time.at(unix_epoch).utc.iso8601
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
        source_data.andand[:venue] || {}
      end

      def composite_location
        v = venue

        country = v[:country] || ""

        if country == 'us'
          country = country.upcase
        else
          country = country.capitalize
        end

        address = [v[:address_1], v[:address_2], v[:address_3]].compact.join(' ')
        city    = [v[:city], v[:state], v[:zip]].compact.join(' ')
        
        "#{v[:name]}, #{address}, #{city}, #{country}"
      end

      def latitude
        v = venue
        (v.andand[:lat] || "").to_s
      end

      def longitude
        v = venue
        (v.andand[:lon] || "").to_s
      end
    end
  end
end
