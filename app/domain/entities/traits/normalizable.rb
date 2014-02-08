module Entities
  module Normalizable
    ARGS_TO_PROPS = ['category', 'project', 'type', 'feed', 'tags', 'origin_author_id', 'origin_author_feed', 'location']

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
      if @instance.missing_critical_tags?
        report_missing_tags
      end
    end

    def clean_junk_from_props
      @instance.props.delete(:tags)
      @instance.props.delete(:origin_author_feed) # Events from Bithub have this
    end

    private
    def report_missing_tags
      missing_tags = %w(feed type category).select{|an| self.instance.send(an).nil?}
      fail Entities::Protocol::MissingCriticalTags.new('must have type, feed and category tags assigned', missing_tags)
    end

    # def to_props_and_clean(args)
    #   ARGS_TO_PROPS.each do |arg|
    #     self.props[arg] = args.delete(arg) if args[arg]
    #   end

    #   self.props['scheduled_for'] = DateTime.parse(args.delete(:datetime)) if args[:datetime] && args[:datetime].present?
    #   args
    # end
  end
end
