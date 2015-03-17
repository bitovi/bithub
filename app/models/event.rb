class Event < ActiveRecord::Base
  belongs_to :entity
  belongs_to :embed
  belongs_to :service

  store_accessor :props
  store_accessor :source_data

  validates_presence_of :content_digest, :embed_id, :service_id
  validates_uniqueness_of :content_digest, scope: [:embed_id, :service_id]

  def deserialize
    Events::Dispatcher.deserialize(self)
  end
end
