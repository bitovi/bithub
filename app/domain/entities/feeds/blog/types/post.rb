require 'entities/procurer'

module Entities
  module Blog
    module Post

      Relationships = {
        upstream: [],
        downstream: []
      }

      class Procurer < Entities::Procurer

        def procure(event)
          if (bp = find_blog_post_by_url(event.extracted['url']))
            fail EventShouldHaveBeenRejected
          else
            build_from_blog_post_event(event.extracted)
          end
        end

        def build_from_blog_post_event(extracted)
          @p.new(extracted)
        end

        def find_blog_post_by_url(url)
          @p.where(url: url).first
        end

      end

    end
  end
end
