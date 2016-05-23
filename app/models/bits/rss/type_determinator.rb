module Bits
  module Rss
    class TypeDeterminator < Bits::TypeDeterminator
      def type_class
        super { Rss::Post }
      end
    end
  end
end
