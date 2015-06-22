module Entities
  module Foursquare
    class TypeDeterminator < Entities::TypeDeterminator
      def type_class
        super { Foursquare::Checkin }
      end
    end
  end
end
