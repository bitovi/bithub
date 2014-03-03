module Determinators
  class CategoryDeterminator

    def self.best_match(entity, rules=nil)
      tags = entity.tag_list
      rules = rules || CategoryDeterminationRule.all
      self.new(tags, rules).best_match
    end

    def initialize(tags, rules=nil)
      @tags = tags
      @rules = rules
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
