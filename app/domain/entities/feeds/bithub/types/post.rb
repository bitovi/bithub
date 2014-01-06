module Entities
  module Bithub
    module Post

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI

        def find(payload)
          if payload.local_id
            find_by_id(payload.local_id).first
          end
        end

        def find_parent(payload)
        end

        def find_children(payload)
        end

        def find_references(payload)
        end

        # Finders
        def find_by_url(url)
          @p.where(url: url)
        end

        def relationships
          Entities::Bithub::Post::Relationships
        end

      end

    end
  end
end
