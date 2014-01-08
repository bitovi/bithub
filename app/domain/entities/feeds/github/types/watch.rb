module Entities
  module Github

    class Watch
      include Entities::Constructable

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def relationships
        Entities::Github::Watch::Relationships
      end
    end

  end
end
