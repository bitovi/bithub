class Event < ActiveRecord::Base
  belongs_to :bit
  belongs_to :hub
  belongs_to :service

  store_accessor :props
  store_accessor :source_data

  validates_presence_of :content_digest, :hub_id, :service_id
  validates_uniqueness_of :content_digest, scope: [:hub_id, :service_id]

  scope :unprocessed, -> { where(was_viewed: false, is_processed: false) }
  scope :processing_failed, lambda { where(was_viewed: true, is_processed: false) }

  def wrapped
    wrapper_class.new(source_data, props, self)
  end

  def wrapper_class
    fn = feed_name.camelize.to_sym; tn = type_name.camelize.to_sym
    if ::Events.constants.include?(fn) && ::Events.const_get(fn).constants.include?(tn)
      ::Events.const_get(fn).const_get(tn)
    end
  end
end
