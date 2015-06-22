module Events
  module Disqus
    class TypeDeterminator < Events::TypeDeterminator
      def type_class
        super { Events::Disqus::PostEvent }
      end
    end
  end
end
