module Entities
  module Instagram
    class TypeDeterminator < Entities::TypeDeterminator
      def type_class
        super { Instagram::Media }
      end
    end
  end
end
