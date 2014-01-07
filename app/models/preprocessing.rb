module Preprocessing

  ARGS_TO_PROPS = [:category, :project, :type, :feed, :tags, :origin_author_id, :origin_author_feed, :location]
    
  def to_props(meta)
    self.props = meta.symbolize_keys
    self
  end

  def to_props_and_clean(args)
    ARGS_TO_PROPS.each do |arg|
      self.props[arg] = args.delete(arg) if args[arg]
    end
    
    self.props[:scheduled_for] = DateTime.parse(args.delete(:datetime)) if args[:datetime] && args[:datetime].present?
    args
  end
end
