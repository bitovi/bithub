class Event < ActiveRecord::Base
  attr_accessible :body, :hash_key, :title, :url
end
