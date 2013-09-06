class Achievement < ActiveRecord::Base
  attr_accessible :note, :achieved_at, :shipped_at

  belongs_to :user
  belongs_to :reward
  validate :user_id, :uniqueness => { :scope => :reward_id }

  after_create :set_timestamp

  def set_timestamp
    self.update_attribute(:achieved_at, Time.now)
  end
end
