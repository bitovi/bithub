module Entities
  module Github

    class Create < Protocol
      include Github::SharedBuilders

      def find
        nil
      end
        
      def data
        with_commons({ title: title })
      end

      private

      def title
        "created a new #{@event.ref_type} on #{@event.repo.name}: #{@event.ref}"
      end
    end

  end
end
