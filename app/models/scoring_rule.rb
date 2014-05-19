require 'acts_as_list'

class ScoringRule < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :name, :required_tags, \
                  :authorship_value, :upvote_value, :award_value, \
                  :valid_until, :position
  attr_readonly :required_tags

  serialize :required_tags, ActiveRecord::Coders::Hstore

  validates_presence_of :authorship_value

  has_many :entities

  acts_as_list

  def required_tags=(tags)
    tags = Tagger.list_to_name_weight_hash tags
    write_attribute(:required_tags, tags)
  end

  def invalidate
    if entities.count == 0
      destroy
    else
      valid_until = Time.now
      save
    end
  end
end
