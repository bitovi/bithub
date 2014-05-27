class FunnelGroup < ActiveRecord::Base
  attr_accessible :name, :display_name, :tags
  validates_presence_of :name
  has_and_belongs_to_many :funnels

  def assoc_funnels(contraints)
    funnels.destroy_all

    constraints.map do |c|
      funnels.create(c)
    end.reduce(true) do |acc, res|
      acc && !!res
    end
  end
end
