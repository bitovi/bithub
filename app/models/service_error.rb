class ServiceError < ActiveRecord::Base
  belongs_to :service
  validates_uniqueness_of :klass, scope: :service_id
end
