module Bits
  module Youtube
    class TypeDeterminator < Bits::TypeDeterminator
      def type_class
        super { Youtube::Video }
      end
    end
  end
end
