module Entities
  module Disqus
    module Post

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      class Procurer
        include Entities::ProcurementAPI

        def procure
          if @payload.post_id && (entity = find_by_post_id.first)
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
        def find_by_post_id
          @persistor.tagged_with('disqus')
            .where("props -> 'post_id' = '#{@payload.post_id}'")
        end

        def relationships
          Entities::Disqus::Post::Relationships
        end
      end

    end
  end
end
