module Preprocessing

  def to_props(meta)
    self.props = meta.symbolize_keys
    self
  end

  def to_props_and_clean(args)
    self.props = {
      category: args.delete(:category),
      project: args.delete(:project),
      feed: args.delete(:feed),
      tags: args.delete(:tags)
    }
    self.props[:location] = args.delete(:location)
    self.props[:scheduled_for] = DateTime.parse(args.delete(:datetime)) if args[:datetime] && args[:datetime].present?
    args
  end
end
