class ScoringRule < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :name, :required_tags, :authorship_value, :upvote_value, :award_value, :priority, :valid_until

  validates_presence_of :authorship_value

  has_many :entities
end
