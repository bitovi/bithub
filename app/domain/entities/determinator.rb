require 'tagging/tagger'
require 'events/shared/mappings'
require 'lib/loggable'

module Entities
  class Determinator
    include Events::Mappings
    include Loggable

    PROPS_TO_TAGS = [:feed, :type, :project, :tags]
    ATTRS_FOR_TAGGING = [:url, :title, :body]

    def initialize(entity)
      initialize_logger
      @e = entity
    end

    def determine
      switch_to_snake_case(@e.props)
      determine_feed
      determine_tags
      determine_category
      determine_rule
      determine_author
      switch_to_camel_case(@e.props)
    end
    
    private

    def determine_feed
      @e.feed = Tag.find_or_create_by_name(@e.props['feed'])
    end

    def determine_tags
      tags = (taggify_props + taggify_content + taggify_labels)
        .flatten
        .compact
        .map {|t| t.snake_case}

      @e.tag_list = ActsAsTaggableOn::TagList.new(tags) unless tags.empty?
    end

    def determine_category
      @logger.debug "Determinator#determine_category, tag_list:#{@e.tag_list}"
      if (category = CategoryDeterminationRule.determine_category(@e.tag_list) || @e.props['category'])
        category = category.snake_case
        @e.tag_list.add(category)
        @e.props['category'] = category
        @e.category = Tag.find_or_create_by_name(category)
      end
      @logger.debug "Determinator#determine_category, category:#{Tag.find(@e.category_id).name}" if @e.category
    end

    def determine_rule
      @e.rule = Rule.best_match(@e.tag_list)
    end

    def determine_author
      uid = @e.props['origin_author_id'] 
      if f = @e.props['origin_author_feed'] # Coming from Bithub
        ident = Identity.find_or_create_with_provider_and_uid(f, uid)
      else f = @e.props['feed'] # Coming from crawler
        ident = Identity.find_by_provider_and_uid(f, uid)
      end

      @e.author = ident.user if ident && ident.user
    end

    def taggify_props

      # some props could be arrays
      search_tags = PROPS_TO_TAGS
      .map {|prop| prop.to_s} # Stringify!
      .map {|prop| @e.props[prop]}
      .flatten
      .compact

      # match tag objects
      search_tags.map {|p| Tag.find_by_name(p) }
      .compact
      .map {|t| t.name}
    end

    def taggify_content
      input = ATTRS_FOR_TAGGING.map {|attr| @e[attr] if @e[attr]}.compact
      Tagger::Engine.new(Tag.projects).find_tags(input)
    end

    def taggify_labels
      if @e.props['labels']
        input = @e.props['labels']
        Tagger::Engine.new(Tag.labels).find_tags(input)
      else
        []
      end
    end

  end
end
