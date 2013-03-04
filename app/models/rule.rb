class Rule < ActiveRecord::Base
  attr_accessible :required_tags, :authorship_value, :upvote_value, :award_value
  has_many :events

  def self.best_match(tags = [])

    # Try to find exact match
    match = Rule.where("required_tags = ?", tags.to_postgres_array(true)).first

    # otherwise try to find best match
    if not match
      score = -1 # will match default rule created by migrations

      self.find_each do |rule|
        if (count = (tags & rule.required_tags).count) > score
          match = rule
          score = count
        end
      end
    end

    return match
  end

  def self.default_rule
    Rule.first
  end

end
