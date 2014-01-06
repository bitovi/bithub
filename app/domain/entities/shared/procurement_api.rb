module Entities
  module ProcurementAPI
    def initialize(persistor)
      @p = persistor
    end

    def procure(payload)
      if (entity = find(payload))
        entity
      else
        build(payload)
      end
    end

    def build(payload)
      entity = @p.new payload.extracted
      entity.props = payload.meta
      entity
    end
  end
end
