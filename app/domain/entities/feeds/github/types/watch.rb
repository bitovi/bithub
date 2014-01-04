module Entities
  module Github
    module Watch

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      class Procurer < Entities::Procurer
        
        def relationships
          Entities::Github::Watch::Relationships
        end
      end

    end
  end
end
