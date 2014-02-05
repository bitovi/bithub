class Entity < ActiveRecord::Base

  class EventHasNoParentException < Error; end
  class DistinctFieldNotKnown < Error; end

  attr_accessible :id,
    :body, :title, :url, :origin_id,
    :tag_list, :owners, :ownerships,
    :feed_name, :type_name, :category_name,
    :feed_id, :type_id, :category_id,
    :origin_ts, :thread_updated_ts,
    :created_at, :updated_at,
    :props, :image, :total_upvotes

  acts_as_taggable
  mount_uploader :image, EventImageUploader
  serialize :props, ActiveRecord::Coders::Hstore

  has_and_belongs_to_many :references_to,
  :class_name => 'Entity',
  :join_table => 'entity_refs',
  :foreign_key => 'from_id',
  :association_foreign_key => "to_id"

  has_and_belongs_to_many :referenced_from,
  :class_name => 'Entity',
  :join_table => 'entity_refs',
  :foreign_key => 'to_id',
  :association_foreign_key => "from_id"

  has_many :events

  has_many :ownerships, foreign_key: :entity_id, dependent: :destroy
  has_many :owners, through: :ownerships, source: :owner

  belongs_to :feed, :foreign_key => "feed_id", :class_name => "Tag"
  belongs_to :type, :foreign_key => "type_id", :class_name => "Tag"
  belongs_to :category, :foreign_key => "category_id", :class_name => "Tag"
  belongs_to :parent, :class_name => "Entity"
  belongs_to :scoring_rule, :foreign_key => "scoring_rule_id", :class_name => "ScoringRule"
  has_many :children, :foreign_key => "parent_id", :class_name => "Entity"
  has_many :upvotes, :foreign_key => "applies_to_id", :dependent => :destroy
  has_many :anteups, :foreign_key => "applies_to_id", :dependent => :destroy
  has_many :awards, :foreign_key => "applies_to_id", :dependent => :destroy

  validates_presence_of  :title,
    :feed_name, :type_name, :category_name,
    :feed_id, :type_id, :category_id,
    :origin_ts, :thread_updated_ts,
    :scoring_rule_id, :tag_list

  scope :feed, lambda {|f| tagged_with f}
  scope :type, lambda {|t| tagged_with t}
  scope :category, lambda {|c| tagged_with c}
  scope :this_week, lambda { where(:origin_date => Date.today.beginning_of_week..Date.today.end_of_week) }
  scope :last_week, lambda { where(:origin_date => 1.weeks.ago.to_date.beginning_of_week..1.week.ago.to_date.end_of_week) }
  scope :x_weeks_ago, lambda {|x| where(:origin_date => x.weeks.ago.to_date.beginning_of_week..x.weeks.ago.to_date.end_of_week) }
  scope :belong_to_a_thread, lambda { where("parent_id IS NOT NULL OR id IN (SELECT parent_id from entities)") }
  scope :have_no_thread, lambda { where("parent_id IS NULL AND id NOT IN (SELECT parent_id from entities)") }
  scope :only_parents, lambda { where("id IN (SELECT parent_id from entities WHERE parent_id IS NOT NULL)") }
  scope :only_children, lambda { where("parent_id IS NOT NULL") }
  scope :not_parents, lambda { where("id NOT IN (SELECT parent_id FROM entities WHERE parent_id IS NOT NULL)") }
  scope :not_children, lambda { where("parent_id IS NULL") }
  scope :with_state, lambda {|state| where("props ? 'state'").where("props -> 'state' = :val", val: state) }
  scope :no_irc_nor_digest, lambda { where("feed_name <> 'irc' AND category_name <> 'digest'") }

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

  def self.scoped_with_includes
    scope = Entity.scoped
    scope = scope.includes(:owners)
    scope = scope.includes(:parent)
    scope
  end

  def author=(user)
    self.ownerships.build(owner: user, type: :author)
  end

  def author
    self.ownerships.select{|a| a.type == 'author'}.first.andand.owner
  end

  def children_with_includes
    self.children.merge(Entity.scoped_with_includes)
  end

  def thread
    if self.parent_id # When an event is a child
      Entity.where("id = ? OR parent_id = ?", self.parent_id, self.parent_id)
    else # When an event is a parent
      Entity.where("id = ? OR parent_id = ?", self.id, self.id)
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
    self.update_attribute(:thread_updated_ts, ts)
  end

  def awarded?
    self.awards.length > 0
  end

  def thread_awarded?
    !self.thread.select{|e| e.awarded?}.blank?
  end

  def sum_upvotes
    self.upvotes.sum('value')
  end

  def update_total_upvotes
    self.update_attribute(:total_upvotes, sum_upvotes)
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

  def last_modified_by
    events.order('created_at DESC').first
  end

  def source_data
    last_modified_by.andand.source_data
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

  private

  # Helper methods
  def self.has_an_attribute?(attr)
    Event.reflections.include?(attr.to_sym) ||
    Event.reflections.include?(attr.to_s.pluralize.to_sym) ||
    Event.attribute_names.include?(attr.to_s) ||
    Event.attribute_names.include?(attr.to_s.pluralize)
  end

  def reformat_uniqueness_validation
    if errors[:hash_key]
      errors[:base].concat(errors.delete(:hash_key))
    end
  end
end
