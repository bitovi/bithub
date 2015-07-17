module Events
  module Tumblr
    class TypeDeterminator < Events::TypeDeterminator
      def type_class
        super { Events::Tumblr::PostEvent }
      end
    end
  end
end
