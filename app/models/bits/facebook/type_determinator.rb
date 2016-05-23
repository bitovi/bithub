module Bits
  module Facebook
    class TypeDeterminator < Bits::TypeDeterminator

      def type_class
        super({ namespace: Facebook, type_name: type_name })
      end

      # Pluck type from Facebook's source_data
      def type_name
        @event.source_data.fetch(:type).capitalize.to_sym
      end
    end
  end
end
