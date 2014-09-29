module Entities
  module Normalizable

    def normalize
      set_thread_ts
      set_total_upvotes
      set_feed_and_type_name
      clean_junk_from_props
      self
    end

    def set_thread_ts
      @instance.thread_updated_ts = @instance.origin_ts
    end

    def set_total_upvotes
      @instance.total_upvotes = 0 if @instance.new_record?
    end
    
    def set_feed_and_type_name
      @instance.feed_name = feed_name.snake_case
      @instance.type_name = type_name.snake_case
    end

    def clean_junk_from_props
      @instance.props.delete(:tags)
      @instance.props.delete(:origin_author_feed) # Events from Bithub have this
    end
  end
end
