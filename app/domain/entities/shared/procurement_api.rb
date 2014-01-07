module Entities
  module ProcurementAPI
    def initialize(persistor, payload)
      @persistor = persistor
      @payload = payload
    end

    def build
      entity = @persistor.new payload.extracted
      entity.props = payload.meta
      entity
    end

    def p
      @persistor
    end
  end
end
