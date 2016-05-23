module Bits
  module Normalizable

    def normalize
      normalize_attributes
      normalize_props
      self
    end
    
    def normalize_attributes
      set_thread_updated_ts
      set_feed_and_type_name
    end

    def normalize_props
      clean_junk_from_props
      set_origin_author_names
    end

    def set_thread_updated_ts
      @instance.thread_updated_ts = @instance.origin_ts
    end

    def set_feed_and_type_name
      @instance.feed_name = feed_name.snake_case
      @instance.type_name = type_name.snake_case
    end

    def clean_junk_from_props
      @instance.props.delete(:tags)
      @instance.props.delete(:origin_author_feed) # Events from Bithub have this
    end
      
    def set_origin_author_names
      @instance.props['origin_author_name'] = '' if !@instance.props['origin_author_name']
      @instance.props['origin_author_username'] = '' if !@instance.props['origin_author_username']
    end
  end
end
