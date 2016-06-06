class Ownership < ActiveRecord::Base
  extend Enumerize

  belongs_to :owner, class_name: "User"
  belongs_to :host, lambda { where(ownership_type: 'host') }, class_name: "User"
  belongs_to :bit

  enumerize :ownership_type, in: [:author, :host, :organizer]

  validates_presence_of :ownership_type
  validates_uniqueness_of :owner_id, scope: [:bit_id, :ownership_type]
  # validates_uniqueness_of :bit_id, scope: [:ownership_type]

  def is_authorship?
    self.ownership_type.to_sym == :author
  end

  def is_hostship?
    self.ownership_type.to_sym == :host
  end

  def is_organizership?
    self.ownership_type.to_sym == :organizer
  end

end
