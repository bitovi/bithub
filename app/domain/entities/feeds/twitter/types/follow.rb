module Entities
  module Twitter
    class Follow

      Relationships = {
        upstream: [],
        downstream: []
      }

      class Procurer < Twitter::Procurer
      end

      module Finders
      end

      module Builders
      end

    end
  end
end

