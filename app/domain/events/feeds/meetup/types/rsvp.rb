module Events
  module Meetup

    class Rsvp < Protocol
      attr_reader :rsvp

      def digest_seed
        rsvp.id.to_s + self.class.name
      end

      def origin_id
        rsvp.id
      end

      def origin_timestamp
        rsvp.created.utc
      end
      
      def wrap_reponse_parts
        @rsvp = Wrappers::Meetup::Rsvp.new(source_data)
      end
    end
  end
end
