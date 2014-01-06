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

        def find(payload)
          if payload.url 
            find_by_url(payload.url).first
          end
        end

        def find_parent(payload)
          if payload.url
            find_by_thread_prefix(payload.url).order("origin_ts ASC").first
          end
        end
        
        def find_children(payload)
          if payload.url
            find_by_thread_prefix(payload.url).where("origin_ts > ?", payload.origin_ts).all
          end
        end

        def find_references(payload)
        end

        private
        def find_by_url(url)
          @p.tagged_with('forum')
            .where(:url => url)
        end

        def find_by_thread_prefix(url)
          thread_url, _ = url.split('#')
          @p.tagged_with(%w(forum post))
            .where("url LIKE '#{thread_url}%'")
        end
        
        def relationships
          Entities::Forum::Post::Relationships
        end
      end

    end
  end
end
