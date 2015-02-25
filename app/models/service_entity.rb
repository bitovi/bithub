class ServiceEntity < ActiveRecord::Base
  belongs_to :embed
  belongs_to :entity
end
