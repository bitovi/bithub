module Bits
  module Meetup
    class TypeDeterminator < Bits::TypeDeterminator

      Mappings = {
        :EventEvent => :Event,
        :RsvpEvent => :Rsvp
      }

      def type_class
        super({ namespace: Meetup, type_name: remapped_type })
      end

      private
      def remapped_type
        Mappings[@event.type_name.to_sym]
      end
    end
  end
end
