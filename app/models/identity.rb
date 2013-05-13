class Identity < ActiveRecord::Base
  attr_accessible :provider, :uid, :source_data
  belongs_to :user
  serialize :source_data, JSON
  validates :uid, :uniqueness => {:scope => :provider}

  def update_source_data_if_blank(source_data)
    self.source_data = source_data if self.source_data.blank? && !source_data.blank?
    save! if self.changed?
  end

  def has_assigned_user?
    !!self.user
  end

  def self.find_or_create_with_oauth_data(oauth_data)
    identity = self.find_by_provider_and_uid(oauth_data['provider'], oauth_data['uid'])
    if identity
      identity.update_source_data_if_blank(oauth_data['info'])
    else
      identity = self.create(uid: oauth_data['uid'], provider: oauth_data['provider'], source_data: oauth_data['info'])
    end
    identity
  end
end
