class Internal < ActiveRecord::Base
  attr_accessible :actor, :receiver, :applies_to, :value, :comment
  belongs_to :applies_to, :class_name => "Event"
  belongs_to :actor, :class_name => "User"
  belongs_to :receiver, :class_name => "User"
  validates_presence_of :receiver, :value

  after_create :update_total_score_in_receiver
  after_destroy :update_total_score_in_receiver
  
  def update_total_score_in_receiver
    self.receiver.update_total_score
  end

  handle_asynchronously :update_total_score_in_receiver
end
