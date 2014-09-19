module Events
  module Normalizable
    
    def normalize
      set_feed_and_type_name
      self
    end

    def set_feed_and_type_name
      @instance.feed_name = feed_name.snake_case
      @instance.type_name = type_name.snake_case
    end
  end
end
