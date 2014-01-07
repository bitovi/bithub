module Entities
  module Forum
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
          if @payload.url
            find_by_thread_prefix.order("origin_ts ASC").first
          end
        end
        
        def procure_children
          if @payload.url
            find_by_thread_prefix.where("origin_ts > ?", @payload.origin_ts).all
          end
        end

        def procure_references
        end

        private
        def find_by_url
          @persistor.tagged_with('forum')
            .where(:url => @payload.url)
        end

        def find_by_thread_prefix
          thread_url, _ = @payload.url.split('#')
          @persistor.tagged_with(%w(forum post))
            .where("url LIKE '#{thread_url}%'")
        end
        
        def relationships
          Entities::Forum::Post::Relationships
        end
      end

    end
  end
end
