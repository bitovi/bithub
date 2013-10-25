module Determination
  class DeterminationException < Exception; end

  PROPS_TO_TAGS = [:feed, :type, :project, :tags, :category]
  ATTRS_FOR_TAGGING = [:url, :title, :body]

  def determine(custom_props = nil)
    self.props ||= custom_props
    self.determine_feed
    self.determine_tags
    self.determine_category
    self.determine_rule
    self.determine_author
    self.clean_props_after_categorization
    self
  end

  def determine_tags
    tags = []

    # cast some magic
    self.props.symbolize_keys!

    # some props should be in tag list by default
    PROPS_TO_TAGS.each {|prop| tags.push self.props[prop] if self.props[prop]}

    # on some we want to run tagger
    input = ATTRS_FOR_TAGGING.map {|attr| self[attr] if self[attr]}
    search_tags = Tag.to_name_aliases_hash(:project)
    tags.concat Tagger::Engine.new(search_tags).find_tags(input)

    # additionaly check issue events
    if self.props[:type] == 'issues_event'
      search_tags = Tag.to_name_aliases_hash(:label)
      tags.concat Tagger::Engine.new(search_tags).find_tags(self.props[:labels])
    end

    self.tag_list = ActsAsTaggableOn::TagList.new(tags) unless tags.empty?
    self
  end

  def determine_feed
    f_raw = (self.props[:feed] || self.props['feed'])
    fail DeterminationException, ":feed missing from props" if f_raw.nil?
    self.feed = Tag.find_by_name(f_raw) || Tag.find_or_create_with_like_by_name(f_raw)
    self
  end

  def determine_category
    if (category = self.props[:category] || CategoryDeterminationRule.determine_category(self.tag_list))
      self.tag_list.add(category)
      self.category = Tag.find_or_create_with_like_by_name(category)
    end
    self
  end

  def determine_rule
    self.rule = Rule.best_match(self.tag_list)
    self
  end

  def determine_author
    p = ActiveSupport::HashWithIndifferentAccess.new(self.props)
    uid = p[:origin_author_id] 
    if f = p[:origin_author_feed] # Coming from Bithub
      ident = Identity.find_or_create_with_provider_and_uid(f, uid)
    else f = p[:feed] # Coming from crawler
      ident = Identity.find_by_provider_and_uid(f, uid)
    end
    self.author = ident.user if ident && ident.user
    self
  end

  def clean_props_after_categorization
    self.props.delete(:project)
    self.props.delete(:tags)
    self.props.delete(:origin_author_feed)
  end

end
