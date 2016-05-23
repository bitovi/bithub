module Bits
  module Foursquare
    class TypeDeterminator < Bits::TypeDeterminator
      def type_class
        super { Foursquare::Checkin }
      end
    end
  end
end
