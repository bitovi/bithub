require 'digest/md5'
require "#{Rails.root}/app/processors/github.rb"
VALID_FEEDS_FOR_IDENT = %w(github twitter)

class Event < ActiveRecord::Base
  extend Finders
  include Preprocessing
  include Determination
  include Grouping
  include Grouping::TwitterSpecific
  include Grouping::GithubSpecific
  include Grouping::ForumsSpecific

  class EventHasNoParentException < Error; end
  class DistinctFieldNotKnown < Error; end

  attr_accessible :hash_key, :id,
    :body, :title, :url,
    :feed, :category, :tag_list, :author,
    :origin_date, :origin_ts,
    :thread_updated_date, :thread_updated_at,
    :created_at, :updated_at,
    :props, :source_data, :image,
    :total_upvotes

  acts_as_taggable_on :tags
  mount_uploader :image, EventImageUploader

  belongs_to :parent, :class_name => "Event"
  belongs_to :rule, :foreign_key => "rule_id", :class_name => "Rule"
  belongs_to :feed, :foreign_key => "feed_id", :class_name => "Tag"
  belongs_to :category, :foreign_key => "category_id", :class_name => "Tag"
  belongs_to :author, :foreign_key => "author_id", :class_name => "User"
  has_many :children, :foreign_key => "parent_id", :class_name => "Event"
  has_many :upvotes, :foreign_key => "applies_to_id", :dependent => :destroy
  has_many :anteups, :foreign_key => "applies_to_id", :dependent => :destroy
  has_many :awards, :foreign_key => "applies_to_id", :dependent => :destroy

  validates_presence_of :origin_date, :origin_ts, :hash_key, :feed_id, :category_id, :rule_id, :tag_list, :title
  validates_uniqueness_of :hash_key, message: 'Post already exists'

  serialize :props, ActiveRecord::Coders::Hstore
  serialize :source_data, JSON

  scope :this_week, lambda { where(:origin_date => Date.today.beginning_of_week..Date.today.end_of_week) }
  scope :last_week, lambda { where(:origin_date => 1.weeks.ago.to_date.beginning_of_week..1.week.ago.to_date.end_of_week) }
  scope :x_weeks_ago, lambda {|x| where(:origin_date => x.weeks.ago.to_date.beginning_of_week..x.weeks.ago.to_date.end_of_week) }
  scope :belong_to_a_thread, lambda { where("parent_id IS NOT NULL OR id IN (SELECT parent_id from events)") }
  scope :have_no_thread, lambda { where("parent_id IS NULL AND id NOT IN (SELECT parent_id from events)") }
  scope :only_parents, lambda { where("id IN (SELECT parent_id from events WHERE parent_id IS NOT NULL)") }
  scope :only_children, lambda { where("parent_id IS NOT NULL") }
  scope :not_parents, lambda { where("id NOT IN (SELECT parent_id FROM events WHERE parent_id IS NOT NULL)") }
  scope :not_children, lambda { where("parent_id IS NULL") }
  scope :with_state, lambda {|state| where("props ? 'state'").where("props -> 'state' = :val", val: state) }
  scope :no_irc_nor_digest, lambda { where("props -> 'feed' <> 'irc' AND props -> 'category' <> 'digest'") }

  after_create :reward_user_if_eligible
  after_create :increase_score_in_author
  after_destroy :decrease_score_in_author

  after_save :update_pagination_table
  after_destroy :update_pagination_table

  after_validation :reformat_uniqueness_validation

  SCOPE_APPLIER_OVERRIDES = {
    :thread_updated_date => Proc.new do |scope, v, params = {}|

      if v.is_a?(String)
        start_date = v
        end_date   = nil
      else
        start_date = v.first
        end_date   = v.last
      end

      if start_date.is_a?(String)
        start_date = Date.parse(start_date)
      end

      if end_date.nil?
        end_date = start_date
      elsif end_date.is_a?(String)
        end_date = Date.parse(end_date)
      end

      end_date = end_date + 1.day - 1.second

      args = [params[:clientTz] || 'UTC', start_date, end_date]
      scope = scope.where("thread_updated_at AT TIME ZONE 'UTC' AT TIME ZONE ? BETWEEN ? AND ?", *args)
    end
  }

  def self.scope_applier_overrides
    SCOPE_APPLIER_OVERRIDES
  end
    
  @processor ||= Processors::Github.new({feed: 'github'})

  def self.github_processor
    @processor
  end

  def self.scoped_with_includes
    scope = Event.uniq.scoped
    scope = scope.includes(:author)
    scope = scope.includes(:category)
    scope = scope.includes(:parent)
    scope = scope.includes(:feed)
    scope
  end

  def children_with_includes
    self.children.merge(Event.scoped_with_includes)
  end

  def initialize(args = {})
    args[:id] = Event.next_id
    super
  end

  def self.new_from_crawler(args = {}, meta)
    ev = self.new(args)
    ev.to_props(meta).determine.group
  end

  def self.new_from_bithub(args)
    event = self.new

    event.hash_key = Digest::MD5.hexdigest(args[:feed] + args[:title] + args[:category] + args[:body])

    attrs = event.to_props_and_clean(args)
    event.determine
    event.origin_and_thread_timestamps_to_now
    event.assign_attributes(attrs)
    event.image = args[:image]
    event
  end

  def update_from_bithub(args)
    attrs = to_props_and_clean(args)
    determine
    assign_attributes(attrs)
    save
  end

  def origin_and_thread_timestamps_to_now
    now                      = DateTime.now
    self.origin_ts           = now.utc
    self.origin_date         = now.utc.to_date
    self.thread_updated_at   = now.utc
    self.thread_updated_date = now.utc.to_date
  end

  def self.next_id
    ActiveRecord::Base.connection.execute("SELECT nextval('#{Event.sequence_name}') AS id;").first['id'].to_i
  end

  def thread
    if self.parent_id # When an event is a child
      Event.where("id = ? OR parent_id = ?", self.parent_id, self.parent_id)
    else # When an event is a parent
      Event.where("id = ? OR parent_id = ?", self.id, self.id)
    end
  end

  def siblings
    parent.children
  end

  def activities
    activities = []
    activities.concat(self.awards)
    activities.concat(self.upvotes)
    activities.concat(self.anteups)
  end

  def bump_thread
    latest_origin_ts = self.thread.pluck(:origin_ts).max
    self.thread.each { |te| te.update_thread_attrs(latest_origin_ts) }
  end

  def update_thread_attrs(ts)
    self.update_attribute(:thread_updated_at, ts)
    self.update_attribute(:thread_updated_date, ts.to_date);
  end

  def update_total_upvotes
    self.update_attribute(:total_upvotes, self.upvotes.sum('value'))
  end

  def awarded?
    self.awards.length > 0
  end

  def thread_awarded?
    !self.thread.select{|e| e.awarded?}.blank?
  end
  
  def sum_upvotes
    (self.upvotes.pluck :value).reduce :+
  end

  def increase_score_in_author
    if self.author
      self.author.total_score += self.rule.authorship_value
      self.author.save!      
    end
  end
  
  def decrease_score_in_author
    if self.author
      self.author.total_score -= self.rule.authorship_value
      self.author.save!      
    end
  end

  def reward_user_if_eligible
    self.author.reward_if_eligible if self.author
  end

  def update_pagination_table
    Pagination.refresh
  end


  def cache_key
    case
    when new_record?
      "#{self.class.model_name.cache_key}/new"
    when (event_updated = self[:updated_at]) && (thread_updated = self[:thread_updated_at])
      event_updated_utc = event_updated.utc.to_s(:number)
      thread_updated_utc = thread_updated.utc.to_s(:number)
      "#{self.class.model_name.cache_key}/#{id}-#{event_updated_utc}-#{thread_updated_utc}"
    when timestamp = self[:updated_at]
      timestamp = timestamp.utc.to_s(:number)
      "#{self.class.model_name.cache_key}/#{id}-#{timestamp}"
    else
      "#{self.class.model_name.cache_key}/#{id}"
    end
  end

  def top_level_parent
    if self.parent
      self.parent.top_level_parent
    else
      self
    end
  end

  def cached_tags
    self.cached_tag_list.split(',').map {|t| t.strip}
  end

  private

  def reformat_uniqueness_validation
    if errors[:hash_key]
      errors[:base].concat(errors.delete(:hash_key))
    end
  end
  
  # Helper methods
  def self.has_an_attribute?(attr)
    Event.reflections.include?(attr.to_sym) ||
    Event.reflections.include?(attr.to_s.pluralize.to_sym) ||
    Event.attribute_names.include?(attr.to_s) ||
    Event.attribute_names.include?(attr.to_s.pluralize)
  end

  def self.prepare_commit(commit_info, push_event)
    custom_sd = push_event.source_data
    .merge(commit_info)
    .merge({type: "CustomCommitEvent"})

    mf_hash = ActiveSupport::HashWithIndifferentAccess.new(custom_sd)
    processed_event_hash = github_processor.process(mf_hash)
    meta = processed_event_hash.delete(:meta)

    [processed_event_hash, meta]
  end
end
