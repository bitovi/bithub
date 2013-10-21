class CategoryDeterminationRule < ActiveRecord::Base
  attr_accessible :name, :scorings
  serialize :scorings, ActiveRecord::Coders::Hstore

  validates_uniqueness_of :name

  def self.determine_category(tags)
    match_best(CategoryDeterminationRule.all, tags)
  end

  def self.match_best(rules, tags)
    best = calculate_scores(rules, tags).max {|a,b| a[:score] <=> b[:score]}
    (best && (best[:score] > 0)) ? best[:name] : nil
  end

  def self.calculate_scores(rules, tags)
    rules.map do |rule|
      score = (rule.scorings.keys & tags).reduce(0) {|score, key| score += rule.scorings[key].to_i}
      {:name => rule.name, :score => score}
    end
  end

end
