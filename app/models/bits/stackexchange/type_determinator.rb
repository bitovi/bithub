module Bits
  module Stackexchange
    class TypeDeterminator < Bits::TypeDeterminator

      Mappings = {
        :QuestionEvent => :Question,
        :AnswerEvent => :Answer,
        :CommentEvent => :Comment
      }

      def type_class
        super({ namespace: Stackexchange, type_name: remapped_type })
      end

      private
      def remapped_type
        Mappings[@event.type_name.to_sym]
      end
    end
  end
end
