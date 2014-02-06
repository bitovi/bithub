module Events
  module Persistable
    def persist
      @instance.save
    end

    def persist!
      @instance.save!
    end
  end
end
