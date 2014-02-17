module Determinators
  class ScoringRuleDeterminator

    def initialize(entity, tags, scoring_rules)
      @entity = entity
      @tags = tags
      @rules = scoring_rules
    end

    def best_match
      return default_rule if @tags.nil? || @tags.empty?

      match = exact_match(tags)

      if match.nil?
        score = -1 # will match default rule created by migrations

        ScoringRule.find_each do |rule|
          count = (tags & rule.required_tags).count
          if count > score
            match = rule
            score = count
          end
        end
      end

      match
    end

    def default_rule
      ScoringRule.where("required_tags = ?", [].to_postgres_array(true)).first
    end

    def exact_match
      ScoringRule.where("required_tags = ?", @tags.to_postgres_array(true)).first
    end

  end
end
