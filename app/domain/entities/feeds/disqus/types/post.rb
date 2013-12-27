module Entities
  module Disqus
    module Post

      Relationships = {
        upstream: [Entities::Disqus::Thread],
        downstream: []
      }

      class Procurer < Entities::Procurer
      end

    end
  end
end
