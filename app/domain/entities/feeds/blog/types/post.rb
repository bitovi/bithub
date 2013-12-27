module Entities
  module Blog
    module Post

      Relationships = {
        upstream: [],
        downstream: []
      }

      class Procurer < Entities::Procurer

        def find(payload, event)
          if url(payload)
            find_by_url(url(payload))
          end
        end

        def build(payload)
          entity = @p.new
          entity.assign_attributes(attrs_from_payload(payload))
          entity.props = props_from_payload(payload)
          @logger.info "NEW: #{entity}"
          entity
        end

        def update(entity, payload)
          entity.assign_attributes(attrs_from_payload(payload))
          @logger.info "PRESENT: #{entity}"
          entity
        end

        # Finders
        def find_by_url(url)
          @p.where(url: url).first
        end

      end

    end
  end
end
