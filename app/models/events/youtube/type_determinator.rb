module Events
  module Youtube
    class TypeDeterminator < Events::TypeDeterminator
      def type_class
        super { Events::Youtube::VideoEvent }
      end
    end
  end
end
