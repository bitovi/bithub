module Entities
  module Bithub
    module Post

      Relationships = {
        upstream: [],
        downstream: [],
        referenced: [],
      }

      class Procurer < Entities::Procurer
        include Entities::Bithub::Accessors

        def find(payload)
          if url(payload)
            find_by_id(id(payload))
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
          Entities::Bithub::Post::Relationships
        end

      end

    end
  end
end
