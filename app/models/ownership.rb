class Ownership < ActiveRecord::Base
  extend Enumerize

  attr_accessible :entity, :owner, :ownership_type, :value

  belongs_to :owner, class_name: "User"
  belongs_to :host, conditions: { ownership_type: 'host' }, class_name: "User"
  belongs_to :entity

  enumerize :ownership_type, in: [:author, :host, :organizer]

  validates_presence_of :ownership_type
  validates_uniqueness_of :owner_id, scope: [:entity_id, :ownership_type]
  # validates_uniqueness_of :entity_id, scope: [:ownership_type]

  after_create :update_total_score_in_owner
  after_destroy :update_total_score_in_owner

  def determine_value
    if self.is_authorship?
      self.value = self.entity.scoring_rule.authorship_value
    elsif self.is_hostship?
      self.value = 10
    elsif self.is_organizership?
      self.value = 15
    end
    self
  end

  def is_authorship?
    self.ownership_type.to_sym == :author
  end

  def is_hostship?
    self.ownership_type.to_sym == :host
  end

  def is_organizership?
    self.ownership_type.to_sym == :organizer
  end

  def update_total_score_in_owner
    self.owner.update_total_score
  end

  handle_asynchronously :update_total_score_in_owner

end
