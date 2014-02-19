class Internal < ActiveRecord::Base
  Variants = [:completed_profile, :linked_twitter, :linked_meetup, :linked_github]

  attr_accessible :actor, :receiver, :applies_to, :value, :comment, :variant

  belongs_to :applies_to, :class_name => "Entity"
  belongs_to :actor, :class_name => "User"
  belongs_to :receiver, :class_name => "User"

  validates_presence_of :receiver, :value
  validates_uniqueness_of :variant, scope: [:receiver_id]

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
    receiver.async_unreward_if_uneligible
  end

  def reward_receiver_if_eligible
    receiver.async_reward_if_eligible
  end
end
