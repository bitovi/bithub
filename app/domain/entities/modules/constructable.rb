module Entities

  module Constructable
    def initialize(persistor, payload)
      @persistor = persistor
      @payload = payload
    end

    def build
      entity = @persistor.new payload.extracted
      entity.props = payload.meta
      entity
    end

    def persist
      @instance.save        
    end

    def persist!
      @instance.save!
    end

    def p
      @persistor
    end
  end

end
