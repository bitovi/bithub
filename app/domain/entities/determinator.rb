module Entities
  class Determinator

  PROPS_TO_TAGS = [:feed, :type, :project, :tags]
  ATTRS_FOR_TAGGING = [:url, :title, :body]

  def initialize(ar_instance, determination_rules)
    @entity = entity
  end

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
    self.props.symbolize_keys!

    tags =
      (taggify_props + taggify_content + taggify_labels)
      .flatten
      .compact
      .map {|t| t.snake_case}
    
    self.tag_list = ActsAsTaggableOn::TagList.new(tags) unless tags.empty?
    self
  end

  def determine_feed
    self.props.symbolize_keys!
    fail DeterminationException, ":feed missing from props" if self.props[:feed].nil?
    self.feed = Tag.find_or_create_by_name(self.props[:feed])
    self
  end

  def determine_category
    self.props.symbolize_keys!

    if (category = CategoryDeterminationRule.determine_category(self.tag_list) || self.props[:category])
      category = category.snake_case
      self.tag_list.add(category)
      self.props[:category] = category
      self.category = Tag.find_or_create_by_name(category)
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
    self.props.delete(:tags)
    self.props.delete(:origin_author_feed)
  end

  def taggify_props
    self.props.symbolize_keys!

    # some props could be arrays
    search_tags = PROPS_TO_TAGS
      .map {|prop| self.props[prop]}
      .flatten
      .compact

    # match tag objects
    search_tags.map {|p| Tag.find_by_name(p) }
      .compact
      .map {|t| t.name}
  end

  def taggify_content
    input = ATTRS_FOR_TAGGING.map {|attr| self[attr] if self[attr]}.compact
    Tagger::Engine.new(Tag.projects).find_tags(input)
  end

  def taggify_labels
    self.props.symbolize_keys!
    
    if self.props[:labels]
      input = self.props[:labels]
      Tagger::Engine.new(Tag.labels).find_tags(input)
    else
      []
    end
  end

end
