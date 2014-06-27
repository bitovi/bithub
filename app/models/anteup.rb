class Anteup < ActiveRecord::Base
  belongs_to :applies_to, :class_name => "Entity"
  belongs_to :actor, :class_name => "User"

  scope :fullfilled, where(:fullfilled => true)

  validates_presence_of :applies_to_id, :actor_id

  def self.create_anteup(actor, entity, value=25)
    if (anteup = Anteup.create({:actor => actor, :applies_to => entity, :value => value, :fullfilled => false}))
      entity.touch
      anteup
    end
  end

  def self.fullfill_all_for(entity)
    fullfill_by(entity)
  end

  def self.fullfill_by(entity)
    Anteup.update_all({fullfilled: true}, {applies_to_id: entity.id})
  end
end
