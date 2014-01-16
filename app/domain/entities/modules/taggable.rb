module Entities
  module Taggable

    ATTRS_FOR_TAGGING = [:url, :title, :body]
    PROPS_TO_TAGS = [:feed, :type, :project, :tags]

    def taggify

      taggify_methods =
        (self.private_methods + self.class.instance_methods(false))
        .select {|m| m.match(/taggify_.*/)}
        .uniq

      tags = taggify_methods
        .reduce([]) {|acc, m| acc += self.send(m)}
        .flatten
        .compact
        .map {|t| t.snake_case}
      
      @instance.tag_list = ActsAsTaggableOn::TagList.new(tags) unless tags.empty?      
    end

    private

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

    # def taggify_labels
    #   if @e.instance.props[:labels]
    #     input = @e.instance.props[:labels]
    #     Tagger.new(Tag.labels).find_tags(input)
    #   else
    #     []
    #   end      
    # end
    
  end  
end
