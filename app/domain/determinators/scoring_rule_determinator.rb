module Determinators
  class ScoringRuleDeterminator

    def self.best_match(entity, rules = nil)
      tags = entity.tag_list
      rules = rules || ScoringRule.all
      self.new(tags, rules).best_match
    end

    def initialize(tags = nil, rules = nil)
      @tags = tags
      @rules = rules
    end

    def best_match
      return default_rule if @tags.nil? || @tags.empty?

      match = exact_match

      if match.nil?
        score = -1 # will match default rule created by migrations

        @rules.each do |rule|
          count = (@tags & rule.required_tags).count
          if count > score
            match = rule
            score = count
          end
        end
      end

      match
    end

    def default_rule
      if @rules && not(@rules.empty?)
        @rules.select{|r| r.required_tags == []}.first
      else
        ScoringRule.where("required_tags = ?", [].to_postgres_array(true)).first
      end
    end

    def exact_match
      if @rules && not(@rules.empty?)
        @rules.select{|r| r.required_tags == @tags.sort}.first
      else
        ScoringRule.where("required_tags = ?", @tags.to_postgres_array(true)).first
      end
    end

  end
end
