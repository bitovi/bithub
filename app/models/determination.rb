module Determination

  def determine(custom_props = nil)
    self.props ||= custom_props
    self.determine_tags
    self.determine_feed
    self.determine_category
    self.determine_rule
    self.determine_author
    self.clean_props_after_categorization
    self
  end

  def determine_tags
    ts = ([] + (self.props[:tags] || []) + [self.props[:feed]] + [self.props[:type]] + [self.props[:category]])
    self.tag_list = ActsAsTaggableOn::TagList.new(ts.uniq)
    self
  end

  def determine_feed
    f = self.props[:feed] || self.props['feed']
    self.feed = Tag.find_by_name(f) || Tag.find_or_create_with_like_by_name(f)
    self
  end

  def determine_category
    c = Tag.basic_tagging(self.props[:category] || self.props['category'])
    self.category = Tag.find_by_name(c) || Tag.find_or_create_with_like_by_name(c)
    self
  end

  def determine_rule
    self.rule = Rule.best_match(self.tag_list)
    self
  end

  def determine_author
    uid = self.props[:origin_author_id]
    if f = self.props[:origin_author_feed] # Coming from Bithub
      ident = Identity.find_or_create_with_provider_and_uid(f, uid)
    else f = self.props[:feed] # Coming from crawler
      ident = Identity.find_by_provider_and_uid(f, uid)
    end
    self.author = ident.user if ident && ident.user
    self
  end

  def clean_props_after_categorization
    self.props.delete(:category)
    self.props.delete(:feed)
    self.props.delete(:project)
    self.props.delete(:tags)
    self.props.delete(:origin_author_feed)
    self.props.delete(:origin_author_id)
  end

end
