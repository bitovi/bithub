module Entities
  module Blog
    module Post

      Relationships = {
        upstream: [],
        downstream: []
      }

      class Procurer < Entities::Procurer
        include Entities::Blog::Accessors

        def find(payload)
          if url(payload)
            find_by_url(url(payload))
          end
        end

        def build(payload)
          entity = @p.new
          entity.assign_attributes(extracted(payload))
          entity.props = meta(payload)
          entity
        end

        def update(entity, payload)
          entity.assign_attributes(extracted(payload))
          entity
        end

        # Finders
        def find_by_url(url)
          @p.where(url: url).first
        end

        def relationships
          Entities::Blog::Post::Relationships
        end
      end

    end
  end
end
