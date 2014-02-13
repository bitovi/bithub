class Internal < ActiveRecord::Base
  attr_accessible :actor, :receiver, :applies_to, :value, :comment
  belongs_to :applies_to, :class_name => "Entity"
  belongs_to :actor, :class_name => "User"
  belongs_to :receiver, :class_name => "User"
  validates_presence_of :receiver, :value

  after_create :update_score_in_receiver_and_check_award_eligibility
  after_destroy :update_score_in_receiver_and_check_award_eligibility
  
  def update_score_in_receiver_and_check_award_eligibility
    update_total_score_in_receiver
    check_if_receiver_still_eligible
    reward_receiver_if_eligible
  end
  
  def update_total_score_in_receiver
    receiver.async_update_total_score
  end

  def check_if_receiver_still_eligible
    receiver.async_validate_eligibility
  end

  def reward_receiver_if_eligible
    receiver.async_reward_if_eligible
  end
end
