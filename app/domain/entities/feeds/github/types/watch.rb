module Entities
  module Github

    class Watch < Protocol

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
