module Determination
  class DeterminationException < Exception; end

  PROPS_TO_TAGS = %w(feed type project tags category)
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
    # cast some magic

    tags =
      (taggify_props + taggify_content + taggify_labels)
      .flatten
      .compact
      .map {|t| t.snake_case}
    
    self.tag_list = ActsAsTaggableOn::TagList.new(tags) unless tags.empty?
    self
  end

  def determine_feed
    feed_name = self.props['feed']
    fail DeterminationException, ":feed missing from props" if feed_name.nil?
    self.feed = Tag.find_or_create_by_name(feed_name)
    self
  end

  def determine_category
    if (category_name = self.props['category'] || CategoryDeterminationRule.determine_category(self.tag_list))
      category_name &&= category_name.snake_case
      self.tag_list.add(category_name)
      self.props['category'] = category_name
      self.category = Tag.find_or_create_by_name(category_name)
    end
    self
  end

  def determine_rule
    self.rule = Rule.best_match(self.tag_list)
    self
  end

  def determine_author
    uid = self.props['origin_author_id'] 
    if f = self.props['origin_author_feed'] # Coming from Bithub
      ident = Identity.find_or_create_with_provider_and_uid(f, uid)
    else f = self.props['feed'] # Coming from crawler
      ident = Identity.find_by_provider_and_uid(f, uid)
    end
    self.author = ident.user if ident && ident.user
    self
  end

  def clean_props_after_categorization
    self.props.delete('tags')
    self.props.delete('origin_author_feed')
  end

  def taggify_props
    PROPS_TO_TAGS.map {|prop| self.props[prop] if self.props[prop]}.compact
  end

  def taggify_content
    input = ATTRS_FOR_TAGGING.map {|attr| self[attr] if self[attr]}.compact
    search_tags = Tag.to_name_aliases_hash(:project)
    Tagger::Engine.new(search_tags).find_tags(input)
  end

  def taggify_labels
    if self.props['labels']
      search_tags = Tag.to_name_aliases_hash(:label)
      input = self.props['labels']
      Tagger::Engine.new(search_tags).find_tags(input)
    else
      []
    end
  end

end
