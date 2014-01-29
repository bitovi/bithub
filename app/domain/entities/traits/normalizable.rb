module Entities
  module Normalizable

    def normalize
      set_thread_ts_to_origin_ts
      set_total_upvotes
      set_feed_and_type_names
      set_ids_for_category_feed_and_type
      clean_junk_from_props
      self
    end

    def set_thread_ts_to_origin_ts
      @instance.thread_updated_ts = @instance.origin_ts
    end

    def set_total_upvotes
      @instance.total_upvotes = 0 if @instance.new_record?
    end

    def set_feed_and_type_names
      @instance.feed_name = feed_name.snake_case
      @instance.type_name = type_name.snake_case
    end

    def set_ids_for_category_feed_and_type
      @instance.category = Tag.find_by_name(@instance.category_name)
      @instance.feed = Tag.find_by_name(@instance.feed_name)
      @instance.type = Tag.find_by_name(@instance.type_name)
    end

    def clean_junk_from_props
      @instance.props.delete(:tags)
      @instance.props.delete(:origin_author_feed) # Events from Bithub have this
    end
  end
end
