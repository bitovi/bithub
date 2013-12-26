require 'tagging/tagger'

module Entities
  class Determinator

    PROPS_TO_TAGS = [:feed, :type, :project, :tags]
    ATTRS_FOR_TAGGING = [:url, :title, :body]

    def initialize
      initialize_logger
    end

    def determine(entity)
      determine_feed(entity)
      determine_tags(entity)
      determine_category(entity)
      determine_rule(entity)
      determine_author(entity)
      clean_props_after_categorization(entity)
    end
    
    private

    def determine_feed(entity)
      entity.feed = Tag.find_or_create_by_name(entity.props['feed'])
    end

    def determine_tags(entity)
      tags = (taggify_props(entity) + taggify_content(entity) + taggify_labels(entity))
        .flatten
        .compact
        .map {|t| t.snake_case}

      entity.tag_list = ActsAsTaggableOn::TagList.new(tags) unless tags.empty?
    end

    def determine_category(entity)
      if (category = CategoryDeterminationRule.determine_category(entity.tag_list) || entity.props['category'])
        category = category.snake_case
        entity.tag_list.add(category)
        entity.props['category'] = category
        entity.category = Tag.find_or_create_by_name(category)
      end
    end

    def determine_rule(entity)
      entity.rule = Rule.best_match(entity.tag_list)
    end

    def determine_author(entity)
      uid = entity.props['origin_author_id'] 
      if f = entity.props['origin_author_feed'] # Coming from Bithub
        ident = Identity.find_or_create_with_provider_and_uid(f, uid)
      else f = entity.props['feed'] # Coming from crawler
        ident = Identity.find_by_provider_and_uid(f, uid)
      end

      entity.author = ident.user if ident && ident.user
    end

    def clean_props_after_categorization(entity)
      entity.props.delete('tags')
      entity.props.delete('origin_author_feed') # Events from Bithub have this
    end

    def taggify_props(entity)

      # some props could be arrays
      search_tags = PROPS_TO_TAGS
      .map {|prop| prop.to_s} # Stringify!
      .map {|prop| entity.props[prop]}
      .flatten
      .compact

      # match tag objects
      search_tags.map {|p| Tag.find_by_name(p) }
      .compact
      .map {|t| t.name}
    end

    def taggify_content(entity)
      input = ATTRS_FOR_TAGGING.map {|attr| entity[attr] if entity[attr]}.compact
      Tagger::Engine.new(Tag.projects).find_tags(input)
    end

    def taggify_labels(entity)
      if entity.props['labels']
        input = entity.props['labels']
        Tagger::Engine.new(Tag.labels).find_tags(input)
      else
        []
      end
    end

    def initialize_logger
      @logger = Log4r::Logger.new('Determinator')
      @logger.add(Log4r::StdoutOutputter.new('console', {
        :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
      }))
    end

  end
end
