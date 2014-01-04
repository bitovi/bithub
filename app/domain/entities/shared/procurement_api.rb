module Procurement
  module API
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

    def find_parent(payload)
      relationships[:upstream].map do |ec|
        ec::Procurer.new(@p).find(payload)
      end
    end

    def find_children(payload)
      relationships[:downstream].map do |ec|
        ec::Procurer.new(@p).find(payload)
      end
    end

    def find_referenced(payload)
      relationships[:references].map do |ec|
        ec::Procurer.new(@p).find(payload)
      end
    end

  end
end
