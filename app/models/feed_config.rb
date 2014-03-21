class FeedConfig < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :feed_name, :config

  serialize :config, JSON

  validates_presence_of  :feed_name
end
