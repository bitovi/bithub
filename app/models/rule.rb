class Rule < ActiveRecord::Base
  attr_accessible :required_tags, :authorship_value, :upvote_value, :award_value
  has_many :events
end
