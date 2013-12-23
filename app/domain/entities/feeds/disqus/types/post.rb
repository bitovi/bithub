module Entities
  module Disqus
    class Post

      Relationships = {
        upstream: [Entities::Disqus::Thread],
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
