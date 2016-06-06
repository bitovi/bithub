class ServiceBit < ActiveRecord::Base
  belongs_to :service
  belongs_to :bit
end
