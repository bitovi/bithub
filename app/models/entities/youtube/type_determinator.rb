module Entities
  module Youtube
    class TypeDeterminator < Entities::TypeDeterminator
      def type_class
        super { Youtube::Video }
      end
    end
  end
end
