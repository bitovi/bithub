class ScoringRule < ActiveRecord::Base
  attr_accessible :required_tags, :authorship_value, :upvote_value, :award_value, :priority
  has_many :entities
end
