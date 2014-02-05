class CategoryDeterminationRule < ActiveRecord::Base
  attr_accessible :name, :scorings
  serialize :scorings, ActiveRecord::Coders::Hstore

  validates_uniqueness_of :name

  def self.best_match(tags, rules = nil)
    rules ||= CategoryDeterminationRule.all
    best = calculate_scores(tags, rules).max {|a,b| a[:score] <=> b[:score]}
    (best && (best[:score] > 0)) ? best[:name] : nil
  end

  def self.calculate_scores(tags, rules = nil)
    rules ||= CategoryDeterminationRule.all
    rules.map do |rule|
      score = (rule.scorings.keys & tags).reduce(0) {|score, key| score += rule.scorings[key].to_i}
      {:name => rule.name, :score => score}
    end
  end

end
