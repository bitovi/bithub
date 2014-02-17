module Determinators
  class CategoryDeterminator

    def initialize(entity, tags, category_rules)
      @entity = entity
      @tags = tags
      @rules = category_rules
    end

    def best_match
      best = category_scores.max {|a,b| a[:score] <=> b[:score]}
      (best && (best[:score] > 0)) ? best[:name] : nil
    end

    def category_scores
      @rules.map do |rule|
        score = (rule.scorings.keys & @tags).reduce(0) {|score, key| score + rule.scorings[key].to_i}
        {:name => rule.name, :score => score}
      end
    end

  end
end
