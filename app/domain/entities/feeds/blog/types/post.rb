module Entities
  module Blog
    module Post

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI

        def procure
          if @payload.url && (entity = find_by_url.first)
            entity
          else
            build
          end
        end

        def procure_parent
        end

        def procure_children
        end

        def procure_references
        end
        
        # Finders
        def find_by_url
          @persistor.where(url: @payload.url)
        end

        def relationships
          Entities::Blog::Post::Relationships
        end
      end

    end
  end
end
