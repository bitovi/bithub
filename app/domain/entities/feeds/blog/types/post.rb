module Entities
  module Blog
    class Post

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
