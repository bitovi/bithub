module Events
  module Stackexchange
    class TypeDeterminator < Events::TypeDeterminator
      def type_class
        super { Events::Stackexchange::QuestionEvent }
      end
    end
  end
end
