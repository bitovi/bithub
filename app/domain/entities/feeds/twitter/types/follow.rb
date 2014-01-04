module Entities
  module Twitter
    module Follow

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI
      end

    end
  end
end
