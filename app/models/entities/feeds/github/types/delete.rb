module Entities
  module Github

    class Delete < Protocol
      include Github::SharedBuilders

      def find
        nil
      end

      def data
        with_commons({ title: title })
      end

      private

      def title
        "deleted a #{@event.ref_type} on #{@event.repo.name}: #{@event.ref}"
      end
    end

  end
end
