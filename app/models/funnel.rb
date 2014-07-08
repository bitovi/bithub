class Funnel < ActiveRecord::Base
  validates_presence_of :name

  has_and_belongs_to_many :constraints,
    class_name: "FunnelConstraint",
    foreign_key: "funnel_id",
    association_foreign_key: "funnel_constraint_id"
end
