module Events
  module Meetup
    class TypeDeterminator < Events::TypeDeterminator
      def type_class
        super do
          if source_data[:rsvp_id]
            Events::Meetup::RsvpEvent
          elsif source_data[:event_url]
            Events::Meetup::EventEvent
          end
        end
      end
    end
  end
end
