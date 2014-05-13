module Tagger
  class Rule
    class InvalidRuleDefinitionException < Exception; end

    attr_reader :required_tags

    def initialize(rule)
      @required_tags = rule[:required_tags].map do |name, weight|
        Tag.new({name: name, weight: weight})
      end
    end

    def rate(tags)
      tags.reduce(0) do |score, tag|
        if t = match_tag(tag)
          score + t.weight
        else
          score
        end
      end
    end

    private

    def match_tag(tag)
      @required_tags
        .select {|t| t[:name] == tag}
        .first
    end

  end
end
