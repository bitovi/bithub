module Entities
  module Disqus
    module Post

      Relationships = {
        upstream: [Entities::Disqus::Thread],
        downstream: []
      }

      class Procurer < Entities::Procurer
        include Entities::Disqus::Accessors

        def find(payload)
          if url(payload)
            find_by_post_id(post_id(payload))
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
        def find_by_post_id(post_id)
          @p.tagged_with('forum')
            .where("props -> 'post_id' = '#{post_id}'")
            .first
        end

        def find_by_thread_url(url)
          thread_url, _ = url.split('#')
          @p.tagged_with('forum')
            .where("url LIKE '#{thread_url}%'")
            .first
        end
      end

    end
  end
end
