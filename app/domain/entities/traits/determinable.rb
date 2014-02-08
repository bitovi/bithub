module Entities
  module Determinable

    ATTRS_FOR_TAGGING = [:url, :title, :body]
    PROPS_TO_TAGS = [:project, :tags]

    def determine
      methods = collect_methods(/determine_.*/)

      # we need to execute :determine_tags before the others 
      methods.unshift(:determine_tags) if methods.delete(:determine_tags)
      
      methods.each {|m| self.send(m)}
      self
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

    
    def determine_category
      if (category = CategoryDeterminationRule.best_match(@instance.tag_list))
        @instance.tag_list.add category.snake_case
        @instance.category_name = category.snake_case
      end
    end

    def determine_rule
      @instance.scoring_rule = ScoringRule.best_match(@instance.tag_list)
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

    private

    def collect_methods(regexp)
      (self.private_methods + self.methods + self.class.instance_methods(false))
        .select {|m| m.match(regexp)}
        .uniq
    end

    def taggify_feed_and_type_name
      [feed_name.snake_case, type_name.snake_case]
    end
    
    def taggify_content
      input = ATTRS_FOR_TAGGING.map {|attr| @instance.send(attr)}.compact
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
