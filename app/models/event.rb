class Event < ActiveRecord::Base
  belongs_to :entity

  store_accessor :props
  store_accessor :source_data

  validates_presence_of :content_digest
  validates_uniqueness_of :content_digest
end
