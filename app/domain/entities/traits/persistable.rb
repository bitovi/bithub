module Entities
  module Persistable

    def set_feed_and_type
      @instance.feed_name = feed_name
      @instance.type_name = type_name
    end

    def persist
      set_feed_and_type
      @instance.save        
    end

    def persist!
      set_feed_and_type
      @instance.save!
    end
  end
end
