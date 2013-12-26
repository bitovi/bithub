require 'entities/procurer'

module Entities
  module Blog
    module Post

      Relationships = {
        upstream: [],
        downstream: []
      }

      class Procurer < Entities::Procurer

        def procure(event, payload)
          build(event, payload)
        end

        def build(event, payload)
          entity = @p.new
          entity.assign_attributes(attrs_from_payload(payload))
          entity.props = props_from_payload(payload)
          # @logger.debug payload['extracted']
          entity
        end

        def find_blog_post_by_url(url)
          @p.where(url: url).first
        end

      end

    end
  end
end
