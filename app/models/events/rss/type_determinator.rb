module Events
  module Rss
    class TypeDeterminator < Events::TypeDeterminator
      def type_class
        super { Events::Rss::PostEvent }
      end
    end
  end
end
