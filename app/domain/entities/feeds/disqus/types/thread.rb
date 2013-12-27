module Entities
  module Disqus
    module Thread

      Relationships = {
        upstream: [],
        downstream: [Entities::Disqus::Post]
      }

      class Procurer < Entities::Procurer
        def initialize
          fail NotImplementedError
        end
      end

    end
  end
end
