module Entities
  module Disqus
    class TypeDeterminator < Entities::TypeDeterminator
      def type_class
        super { Disqus::Post }
      end
    end
  end
end
