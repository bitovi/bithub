class Ownership < ActiveRecord::Base
  extend Enumerize

  attr_accessible :entity, :owner, :type, :value

  belongs_to :owner, class_name: "User"
  belongs_to :entity
  belongs_to :scoring_rule
  enumerize :type, in: [:author, :host, :organizer]

  validates_presence_of :type
  validates_uniqueness_of :owner_id, scope: [:entity_id, :type]
end
