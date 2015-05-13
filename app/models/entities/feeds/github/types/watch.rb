module Entities
  module Github

    class Watch < Protocol
      include Github::SharedBuilders

      def find
        nil
      end

      def data
        with_commons({
          title: "started watching #{@event.repo.name}"
        })
      end
    end

  end
end
