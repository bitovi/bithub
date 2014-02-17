class Award < ActiveRecord::Base
  attr_accessible :actor, :applies_to, :value

  belongs_to :applies_to, :class_name => "Entity"
  belongs_to :actor, :class_name => "User"

  validates_presence_of :applies_to_id
  validates_uniqueness_of :actor_id, scope: :applies_to_id, message: "may only award once"
  validate :thread_not_already_awarded
  
  after_create :bust_event_cache

  # Validator
  def thread_not_already_awarded
    already_awarded? = applies_to.thread
    .select{|e| e.awarded?}
    .map{|e| !e.awards.include?(self)}
    .reduce(false) {|acc, v| acc && v}
      
    if already_awarded?
      errors.add(:applies_to, "can't already be in an awarded thread")
    end
  end

  def bust_event_cache
    self.applies_to.touch
    self.applies_to.parent.touch if self.applies_to.parent
    self.applies_to.parent.parent.touch if self.applies_to.parent && self.applies_to.parent.parent
  end

end
