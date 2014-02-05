class Ownership < ActiveRecord::Base
  extend Enumerize

  attr_accessible :entity, :owner, :ownership_type, :value

  belongs_to :owner, class_name: "User"
  belongs_to :entity
  belongs_to :scoring_rule
  enumerize :ownership_type, in: [:author, :host, :organizer]

  validates_presence_of :ownership_type
  validates_uniqueness_of :owner_id, scope: [:entity_id, :ownership_type]

  def determine_value
    Rails.logger.debug self.inspect
    if self.ownership_type == :author
      self.value = self.entity.scoring_rule.ownership_value
    elsif self.ownership_type == :host
      self.value = 10
    elsif self.ownership_type == :organizer
      self.value = 15
    end
    self
  end
end
