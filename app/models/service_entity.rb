class ServiceEntity < ActiveRecord::Base
  belongs_to :service
  belongs_to :entity
end
