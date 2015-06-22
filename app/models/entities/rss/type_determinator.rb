module Entities
  module Rss
    class TypeDeterminator < Entities::TypeDeterminator
      def type_class
        super { Rss::Post }
      end
    end
  end
end
