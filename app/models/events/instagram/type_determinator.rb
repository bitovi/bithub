module Events
  module Instagram
    class TypeDeterminator < Events::TypeDeterminator
      def type_class
        super { Events::Instagram::MediaEvent }
      end
    end
  end
end
