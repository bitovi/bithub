require 'digest/md5'

class Event < ActiveRecord::Base

  attr_accessible :content_digest, :feed, :type,
    :created_at, :updated_at, :extracted,
    :source_data, :source_json

  validates_presence_of :content_digest
  validates_uniqueness_of :content_digest

  serialize :source_data, JSON

  belongs_to :entity

end

#   def initialize(args = {})
#     args[:id] = Event.next_id
#     super
#   end

#   def self.new_from_crawler(args = {}, meta)
#     ev = self.new(args)
#     ev.to_props(meta).determine.group
#   end

#   def self.new_from_bithub(args)
#     event = self.new

#     event.hash_key = Digest::MD5.hexdigest(args[:feed] + args[:title] + args[:category] + args[:body])

#     attrs = event.to_props_and_clean(args)
#     event.determine
#     event.origin_and_thread_timestamps_to_now
#     event.assign_attributes(attrs)
#     event.image = args[:image]
#     event
#   end

#   def update_from_bithub(args)
#     attrs = to_props_and_clean(args)
#     determine
#     assign_attributes(attrs)
#     save
#   end
