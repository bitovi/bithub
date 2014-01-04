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

        def find(payload)
          if payload.url
            find_by_url(payload.url).first
          end
        end


        # Finders
        def find_by_url(url)
          @p.where(url: url)
        end

        def relationships
          Entities::Blog::Post::Relationships
        end
      end

    end
  end
end
