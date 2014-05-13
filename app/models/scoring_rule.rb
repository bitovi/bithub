class ScoringRule < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :name, :required_tags, \
                  :authorship_value, :upvote_value, :award_value, \
                  :valid_until

  attr_readonly :required_tags

  serialize :required_tags, ActiveRecord::Coders::Hstore

  validates_presence_of :authorship_value

  has_many :entities

  def invalidate!
    if entities.count == 0
      destroy!
    else
      valid_until = Time.now
      save!
    end
  end

end
