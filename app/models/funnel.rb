class Funnel < ActiveRecord::Base
  attr_accessible :feed_name, :type_name
  validates_presence_of :feed_name, :type_name
  has_and_belongs_to_many :funnel_groups

  def constraints
    { :type_name => type_name, :feed_name => feed_name }
  end
end
