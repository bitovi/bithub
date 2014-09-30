class Service < ActiveRecord::Base

  belongs_to :embed
  has_one :filter, as: :filterable, :dependent => :destroy

end
