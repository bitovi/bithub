class Funnel < ActiveRecord::Base

  include RankedModel
  ranks :position

  validates_presence_of :name

  has_and_belongs_to_many :constraints,
    class_name: "FunnelConstraint",
    foreign_key: "funnel_id",
    association_foreign_key: "funnel_constraint_id"


  def disabled=(value)
    self.props_will_change!
    self.props['disabled'] = (!!value).to_s
  end

  def disabled
    disabled = self.props['disabled']
    return true if disabled == true or disabled == 'true'
    return false
  end

  def covers?(entity)
    (constraints.map{|c| c.feed_name}.include?(entity.feed_name)) && (constraints.map {|c| c.type_name}.include?(entity.type_name))
  end

  def weight
    (constraints.count * 1) + (tags.count * 10)
  end
end
