module Bits
  module Instagram
    class TypeDeterminator < Bits::TypeDeterminator
      def type_class
        super { Instagram::Media }
      end
    end
  end
end
