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

        def find(payload)
          if payload.post_id
            find_by_post_id(payload.post_id).first
          end
        end

        def find_parent(payload)
        end

        def find_children(payload)
        end

        def find_references(payload)
        end

        # Finders
        def find_by_post_id(post_id)
          @p.tagged_with('disqus')
            .where("props -> 'post_id' = '#{post_id}'")
        end

        def relationships
          Entities::Disqus::Post::Relationships
        end
      end

    end
  end
end
