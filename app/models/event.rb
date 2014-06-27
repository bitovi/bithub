class Event < ActiveRecord::Base
  belongs_to :entity

  validates_presence_of :content_digest
  validates_uniqueness_of :content_digest
end
