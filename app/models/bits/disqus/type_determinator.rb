module Bits
  module Disqus
    class TypeDeterminator < Bits::TypeDeterminator
      def type_class
        super { Disqus::Post }
      end
    end
  end
end
