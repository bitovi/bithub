class Event < ActiveRecord::Base
  belongs_to :entity

  attr_accessible :content_digest,
    :feed_name, :type_name,
    :created_at, :updated_at,
    :source_data, :source_json,
    :props

  validates_presence_of :content_digest
  validates_uniqueness_of :content_digest

  serialize :source_data, JSON
  serialize :props, ActiveRecord::Coders::Hstore

end
