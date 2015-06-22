module Entities
  module Tumblr
    class TypeDeterminator < Entities::TypeDeterminator

      def type_class
        super({ namespace: Tumblr, type_name: type_name })
      end

      # Tumblr sends a type attribute in the response,
      # which we read and use to determine the type_name
      def type_name
        @event.source_data.fetch(:type).capitalize.to_sym
      end
    end
  end
end
