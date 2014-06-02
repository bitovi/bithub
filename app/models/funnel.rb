class Funnel < ActiveRecord::Base
  attr_accessible :name, :display_name, :tags
  validates_presence_of :name
  has_and_belongs_to_many :constraints,
    class_name: "FunnelConstraint",
    foreign_key: "funnel_id",
    association_foreign_key: "funnel_constraint_id"

  def assoc_funnels(contraints)
    funnels.destroy_all

    constraints.map do |c|
      funnels.create(c)
    end.reduce(true) do |acc, res|
      acc && !!res
    end
  end
end
