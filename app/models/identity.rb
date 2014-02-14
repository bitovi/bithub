class Identity < ActiveRecord::Base
  attr_accessible :provider, :uid, :source_data
  belongs_to :user
  serialize :source_data, JSON
  validates_uniqueness_of :uid, scope: :provider

  def update_source_data_if_blank(data)
    self.update_attribute(:source_data, data) if self.source_data.blank? && !data.blank?
  end

  def name
    source_data['name']
  end

  def nickname
    source_data['nickname']
  end

  def email
    source_data['email']
  end

  def name
    source_data['name']
  end

  def self.find_or_create_with_oauth_data(oauth_data)
    self.find_or_create_with_provider_and_uid(oauth_data['provider'], oauth_data['uid'], oauth_data['info'])
  end

  def self.new_from_oauth(oauth_data)
    self.new(
      uid:         oauth_data['uid'],
      provider:    oauth_data['provider'],
      source_data: oauth_data['info']
    )
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
  
  def self.find_or_init_with_provider_and_uid(provider, uid, source_info=nil)
    identity = self.find_by_provider_and_uid(provider, uid)
    if identity
      identity.update_source_data_if_blank(source_info) if source_info
    else
      identity = self.new(uid: uid, provider: provider, source_data: source_info)
    end
    identity
  end
end
