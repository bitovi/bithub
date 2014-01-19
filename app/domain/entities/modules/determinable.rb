module Entities
  module Determinable

    ATTRS_FOR_TAGGING = [:url, :title, :body]
    PROPS_TO_TAGS = [:feed, :type, :project, :tags]

    def determine_feed
      @instance.feed = Tag.find_or_create_by_name(@instance.props[:feed])
    end

    def determine_category
      if (category = CategoryDeterminationRule.determine_category(@instance.tag_list) || @instance.props[:category])
        category = category.snake_case
        @instance.tag_list.add(category)
        @instance.props[:category] = category
        @instance.category = Tag.find_or_create_by_name(category)
      end
    end

    def determine_rule
      @instance.rule = ScoringRule.best_match(@instance.tag_list)
    end

    def determine_author
      uid = @instance.props[:origin_author_id] 
      if f = @instance.props[:origin_author_feed] # Coming from Bithub
        ident = Identity.find_or_create_with_provider_and_uid(f, uid)
      else f = @instance.props[:feed] # Coming from crawler
        ident = Identity.find_by_provider_and_uid(f, uid)
      end

      @instance.author = ident.user if ident && ident.user
    end

    def determine_tags

      taggify_methods = collect_methods(/taggify_.*/)

      tags = taggify_methods
        .reduce([]) {|acc, m| acc += self.send(m)}
        .flatten
        .compact
        .map {|t| t.snake_case}
      
      @instance.tag_list = ActsAsTaggableOn::TagList.new(tags) unless tags.empty?      
    end

    private

    def collect_methods(regexp)
      (self.private_methods + self.class.instance_methods(false))
        .select {|m| m.match(regexp)}
        .uniq      
    end
    
    def taggify_content
      input = ATTRS_FOR_TAGGING.map {|attr| @instance[attr] if @instance[attr]}.compact
      Tagger.new(Tag.projects).find_tags(input)
    end

    def taggify_props
      search_tags = PROPS_TO_TAGS
        .map {|prop| @instance.props[prop]}
        .flatten
        .compact

      # match tag objects
      search_tags.map {|p| Tag.find_by_name(p) }
        .compact
        .map {|t| t.name}      
    end

  end  
end
