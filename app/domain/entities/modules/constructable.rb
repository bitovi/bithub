module Entities

  module Constructable
    def initialize(payload)
      @payload = payload
    end

    def persist
      @instance.save        
    end

    def persist!
      @instance.save!
    end
  end

end
