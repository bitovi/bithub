class ScoringRule< ActiveRecord::Base
  attr_accessible :required_tags, :authorship_value, :upvote_value, :award_value, :priority
  has_many :events

  def self.best_match(tags = [])
    return self.default_rule unless tags && tags.count > 0

    # Try to find exact match
    match = self.exact_match(tags)

    # otherwise try to find best match
    if match.nil?
      score = -1 # will match default rule created by migrations

      self.find_each do |rule|
        count = (tags & rule.required_tags).count
        if count > score
          match = rule
          score = count
        end
      end
    end

    return match
  end

  def self.default_rule
    Rule.where("required_tags = ?", [].to_postgres_array(true)).first
  end

  def self.exact_match(tags)
    Rule.where("required_tags = ?", tags.to_postgres_array(true)).first
  end
end
