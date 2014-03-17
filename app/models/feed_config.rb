class FeedConfig < ActiveRecord::Base
  attr_accessible :feed_name, :config

  serialize :config, JSON
end
