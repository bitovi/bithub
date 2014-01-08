require 'digest/md5'

class Event < ActiveRecord::Base

  attr_accessible :content_digest, :feed, :type,
    :created_at, :updated_at, :extracted,
    :source_data, :source_json

  validates_presence_of :content_digest
  validates_uniqueness_of :content_digest

  serialize :extracted, JSON
  serialize :source_data, JSON
  serialize :source_json, JSON

  #belongs_to :entity

  # def initialize(args = {})
  #   args[:id] = Event.next_id
  #   super
  # end


  # def self.new_from_crawler(args = {}, meta)
  #   ev = self.new(args)
  #   ev.to_props(meta).determine.group
  # end

  # def self.new_from_bithub(args)
  #   event = self.new

  #   event.hash_key = Digest::MD5.hexdigest(args[:feed] + args[:title] + args[:category] + args[:body])

  #   attrs = event.to_props_and_clean(args)
  #   event.determine
  #   event.origin_and_thread_timestamps_to_now
  #   event.assign_attributes(attrs)
  #   event.image = args[:image]
  #   event
  # end

  # def update_from_bithub(args)
  #   attrs = to_props_and_clean(args)
  #   determine
  #   assign_attributes(attrs)
  #   save
  # end


  # def self.next_id
  #   ActiveRecord::Base.connection.execute("SELECT nextval('#{Event.sequence_name}') AS id;").first['id'].to_i
  # end

  # def cache_key
  #   case
  #   when new_record?
  #     "#{self.class.model_name.cache_key}/new"
  #   when (event_updated = self[:updated_at]) && (thread_updated = self[:thread_updated_at])
  #     event_updated_utc = event_updated.utc.to_s(:number)
  #     thread_updated_utc = thread_updated.utc.to_s(:number)
  #     "#{self.class.model_name.cache_key}/#{id}-#{event_updated_utc}-#{thread_updated_utc}"
  #   when timestamp = self[:updated_at]
  #     timestamp = timestamp.utc.to_s(:number)
  #     "#{self.class.model_name.cache_key}/#{id}-#{timestamp}"
  #   else
  #     "#{self.class.model_name.cache_key}/#{id}"
  #   end
  # end

  # private
  
  # # Helper methods
  # def self.has_an_attribute?(attr)
  #   Event.reflections.include?(attr.to_sym) ||
  #   Event.reflections.include?(attr.to_s.pluralize.to_sym) ||
  #   Event.attribute_names.include?(attr.to_s) ||
  #   Event.attribute_names.include?(attr.to_s.pluralize)
  # end

  # def self.prepare_commit(commit_info, push_event)
  #   custom_sd = push_event.source_data
  #   .merge(commit_info)
  #   .merge({type: "CustomCommitEvent"})

  #   mf_hash = ActiveSupport::HashWithIndifferentAccess.new(custom_sd)
  #   processed_event_hash = github_processor.process(mf_hash)
  #   meta = processed_event_hash.delete(:meta)

  #   [processed_event_hash, meta]
  # end
end
