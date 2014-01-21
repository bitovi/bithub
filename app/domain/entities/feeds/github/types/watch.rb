module Entities
  module Github

    class Watch
      include Entities::Constructable
      include Entities::Determinable
      
      attr_reader :instance

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
