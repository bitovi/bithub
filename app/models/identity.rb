class Identity < ActiveRecord::Base
  attr_accessible :provider, :uid, :source_data
  belongs_to :user
  serialize :source_data, JSON
  
  def self.find_with_omniauth(auth)
    find_by_provider_and_uid(auth['provider'], auth['uid'])
  end
end
