class Identity < ActiveRecord::Base
  attr_accessible :provider, :uid, :source_data
  belongs_to :user
  serialize :source_data, JSON
  validates_uniqueness_of :uid, scope: :provider

  def update_source_data_if_blank(data)
    self.update_attribute(:source_data, data) if self.source_data.blank? && !data.blank?
  end

  def already_linked_to_other_user?
    has_assigned_user? && user.identities.count > 1
  end

  def has_assigned_user?
    !!self.user
  end

  def self.find_or_create_with_provider_and_uid(provider, uid, source_info=nil)
    identity = self.find_by_provider_and_uid(provider, uid)
    if identity && source_info
      identity.update_source_data_if_blank(source_info)
    elsif !identity
      identity = self.create(uid: uid, provider: provider, source_data: source_info)
    end
    identity
  end

  def self.find_or_create_with_oauth_data(oauth_data)
    self.find_or_create_with_provider_and_uid(oauth_data['provider'], oauth_data['uid'], oauth_data['info'])
  end
end
