class ScoringRule < ActiveRecord::Base

  validates_presence_of :authorship_value

  has_many :entities

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
