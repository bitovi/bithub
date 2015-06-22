module Events
  module Foursquare
    class TypeDeterminator < Events::TypeDeterminator
      def type_class
        super { Events::Foursquare::CheckinEvent }
      end
    end
  end
end
