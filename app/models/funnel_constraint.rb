class FunnelConstraint < ActiveRecord::Base
  validates_presence_of :feed_name, :type_name

  has_and_belongs_to_many :funnels

  def constraints
    { :type_name => type_name, :feed_name => feed_name }
  end
end
