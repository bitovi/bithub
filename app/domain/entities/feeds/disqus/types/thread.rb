module Entities
  module Disqus
    class Thread

      Relationships = {
        upstream: [],
        downstream: [Entities::Disqus::Post]
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
