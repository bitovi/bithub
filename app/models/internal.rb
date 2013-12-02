class Internal < ActiveRecord::Base
  attr_accessible :actor, :receiver, :applies_to, :value, :comment
  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"
  belongs_to :receiver, :class_name => "User"
  validates_presence_of :receiver, :value

  after_create :increase_score_in_associated_user!
  after_destroy :decrease_score_in_associated_user!

  def increase_score_in_associated_user!
    self.receiver.total_score += self.value
    self.receiver.save!
  end
  
  def decrease_score_in_associated_user!
    self.receiver.total_score -= self.value
    self.receiver.save!
  end
end
