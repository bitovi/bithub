class EntityRef < ActiveRecord::Base
  belongs_to :source, foreign_key: "from_id", class_name: "Entity"
  belongs_to :target, foreign_key: "to_id", class_name: "Entity"

  validates_uniqueness_of :from_id, scope: :to_id

end
