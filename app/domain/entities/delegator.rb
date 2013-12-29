module Entities
  class Delegator
    include Entities::Accessors

    def initialize(persistor)
      @p = persistor
    end

    def procurer(payload)
      @subprocurer ||= Entities.const_get(feed(payload)).const_get(type(payload))::Procurer.new(@p)
    end
  end
end
