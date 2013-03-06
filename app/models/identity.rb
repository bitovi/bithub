class Identity < ActiveRecord::Base
  attr_accessible :provider, :uid, :raw_json
  belongs_to :user
  serialize :raw_json, JSON
  
  def self.find_with_omniauth(auth)
    find_by_provider_and_uid(auth['provider'], auth['uid'])
  end
end
