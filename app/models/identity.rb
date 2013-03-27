class Identity < ActiveRecord::Base
  attr_accessible :provider, :uid, :source_data
  belongs_to :user
  serialize :source_data, JSON
  validates :uid, :uniqueness => {:scope => :provider}

  def update_source_data_if_blank(source_data)
    self.source_data = source_data if self.source_data.blank? && !source_data.blank?
    save! if self.changed?
  end
  
  def self.find_with_omniauth(auth)
    find_by_provider_and_uid(auth['provider'], auth['uid'])
  end
end
