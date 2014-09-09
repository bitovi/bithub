class Entity < ActiveRecord::Base
  extend Solipsism

  store_accessor :props

  acts_as_taggable
  mount_uploader :image, EventImageUploader

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
  has_many :hosts, through: :ownerships, source: :host

  belongs_to :feed, :foreign_key => "feed_id", :class_name => "Tag"
  belongs_to :type, :foreign_key => "type_id", :class_name => "Tag"
  belongs_to :parent, :class_name => "Entity"
  belongs_to :scoring_rule, :foreign_key => "scoring_rule_id", :class_name => "ScoringRule"
  has_many :children, :foreign_key => "parent_id", :class_name => "Entity"
  has_many :upvotes, :foreign_key => "applies_to_id", :dependent => :destroy
  has_many :awards, :foreign_key => "applies_to_id", :dependent => :destroy

  validates_presence_of  :title,
    :feed_name, :type_name,
    :feed_id, :type_id,
    :origin_ts, :thread_updated_ts,
    :scoring_rule_id, :tag_list

  # Basic
  scope :feed, lambda {|f| where(feed_name: f) }
  scope :no_feed, lambda {|f| where("feed_name <> ?", f) }
  scope :type, lambda {|t| where(type_name: t) }
  scope :no_type, lambda {|t| where("type_name <> ?", t) }

  scope :without_future, lambda { |clientTz|
    where("thread_updated_ts AT TIME ZONE 'UTC' AT TIME ZONE ? < date_trunc('day', now() AT TIME ZONE ?) + interval '1 day'", clientTz, clientTz)
  }

  scope :in_future, lambda { |clientTz|
    where("thread_updated_ts AT TIME ZONE 'UTC' AT TIME ZONE ? > date_trunc('day', now() AT TIME ZONE ?)", clientTz, clientTz)
  }

  # Thread belonging
  scope :belong_to_a_thread, lambda { where("parent_id IS NOT NULL OR id IN (SELECT parent_id from entities)") }
  scope :have_no_thread, lambda { where("parent_id IS NULL AND id NOT IN (SELECT parent_id from entities)") }

  # Parent/child
  scope :only_parents, lambda { where("id IN (SELECT parent_id from entities WHERE parent_id IS NOT NULL)") }
  scope :only_children, lambda { where("parent_id IS NOT NULL") }
  scope :no_parents, lambda { where("id NOT IN (SELECT parent_id FROM entities WHERE parent_id IS NOT NULL)") }
  scope :no_children, lambda { where("parent_id IS NULL") }

  # Authorship
  scope :origin_author, lambda {|uid| where("props -> 'origin_author_id' = :uid", uid: uid.to_s) }
  scope :origin_host, lambda {|uid| where("string_to_array(props -> 'event_host_ids_csv', ',') @> string_to_array(:uid, ',') OR string_to_array(props -> 'event_host_ids', ',') @> string_to_array(:uid, ',')", uid: uid.to_s) }

  # Issues
  scope :number, lambda {|n| where("props ? 'number'").where("props -> 'number' = :val", val: n.to_s) }
  scope :repo_name, lambda {|rn| where("props ? 'repo_name'").where("props -> 'repo_name' = :val", val: rn) }
  scope :with_state, lambda {|state| where("props ? 'state'").where("props -> 'state' = :val", val: state) }

  scope :scoped_with_includes, lambda { includes(:owners).includes(:parent) }

  scope :from_funnel, lambda { |funnel| tagged_with funnel.tags, :any => true if funnel.tags && funnel.tags.present?}
  scope :from_funnel_constraint, lambda { |constraint| where constraint.as_hash }

  after_create :reward_user_if_eligible
  after_create :increase_score_in_author
  after_create :adopt_references_from_children
  after_destroy :decrease_score_in_author

  after_save :update_pagination_table
  after_destroy :update_pagination_table

  after_validation :reformat_uniqueness_validation


  def self.with_author(author_id)
    joins(:ownerships)\
      .where("ownerships.ownership_type = 'author'")\
      .where("ownerships.owner_id = ?", author_id) if author_id
  end

  def self.with_host(host_id)
    joins(:ownerships)\
      .where("ownerships.ownership_type = 'host'")\
      .where("ownerships.owner_id = ?", host_id) if host_id
  end

  def author=(user)
    self.remove_author
    self.ownerships << Ownership.new(owner: user, entity: self, ownership_type: :author).determine_value
  end

  def event_hosts=(users)
    self.remove_hosts
    users.each do |u|
      self.ownerships << Ownership.new(owner: u, entity: self, ownership_type: :host).determine_value
    end
  end

  def remove_author
    self.ownerships.where(ownership_type: :author).destroy_all
  end

  def remove_hosts
    self.ownerships.where(ownership_type: :host).destroy_all
  end

  def author
    self.ownerships.select{|a| a.is_authorship? }.first.andand.owner
  end

  def state
    self.props.andand["state"]
  end

  def label_names
    self.props.andand["label_names"]
  end

  def children_with_includes
    self.children.merge(Entity.scoped_with_includes)
  end

  def references_with_includes()
    self.referenced_from.merge(Entity.scoped_with_includes)
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
  end

  # FIXME, should be delegated to a proper type from Entities
  def bump_thread
    if self.feed_name == 'meetup' && self.type_name == 'event'
      latest_origin_ts = self.thread.pluck(:props).map{|p| p['scheduled_at']}.compact.map {|t| Time.parse t}.max
    else
      latest_origin_ts = self.thread.pluck(:origin_ts).max
    end
    self.thread.each { |te| te.update_thread_attrs(latest_origin_ts) }
  end

  def update_thread_attrs(ts)
    self.update_attribute(:thread_updated_ts, ts)
  end

  def latest_thread_ts
    self.thread.pluck(:origin_ts).max
  end

  def latest_child_ts
    self.children.order("origin_ts DESC").first.andand.origin_ts
  end

  def awarded?
    self.awards.length > 0
  end

  def thread_awarded?
    !self.thread.select{|e| e.awarded?}.blank?
  end

  def sum_upvotes
    self.upvotes.sum(:value)
  end

  def update_total_upvotes
    self.update_attribute(:total_upvotes, sum_upvotes)
  end

  def async_update_total_upvotes
    Workers::EntitiesTotalVotesUpdater.perform_async self.id
  end

  def increase_score_in_author
    if self.author
      self.author.total_score += self.scoring_rule.authorship_value
      self.author.save!
    end
  end

  def decrease_score_in_author
    if self.author
      self.author.total_score -= self.scoring_rule.authorship_value
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
    when (event_updated = self[:updated_at]) && (thread_updated = self[:thread_updated_ts])
      event_updated_utc = event_updated.utc.to_s(:number)
      thread_updated_utc = thread_updated.utc.to_s(:number)
      "#{self.class.model_name.cache_key}/#{id}-#{event_updated_utc}-#{thread_updated_utc}"
    else
      "#{self.class.model_name.cache_key}/#{id}"
    end
  end

  def missing_critical_tags?
    !self.type || !self.feed
  end

  def adopt_references_from_children
    #return
    children = self.children.pluck(:id)

    unless children.empty?
      references_to   = EntityRef.where(to_id: children).all
      references_from = EntityRef.where(from_id: children).all

      references_to_ids   = Entity.where(id: references_to.pluck(:from_id).uniq).map { |e|
        e.parent ? e.parent_id : e.id
      }.uniq.compact

      references_from_ids = Entity.where(id: references_from.pluck(:to_id).uniq).map { |e|
        e.parent ? e.parent_id : e.id
      }.uniq.compact

      references_to.map(&:destroy)
      references_from.map(&:destroy)

      references_to_ids.map do |from_id|
        EntityRef.create_reference({from_id: from_id, to_id: self.id}) if from_id != self.id
      end

      references_from_ids.map do |to_id|
        EntityRef.create_reference({to_id: to_id, from_id: self.id}) if to_id != self.id
      end

      EntityRef.where(from_id: self.id).joins(:target).where('COALESCE(entities.parent_id, 0) <> 0').destroy_all
      EntityRef.where(to_id: self.id).joins(:source).where('COALESCE(entities.parent_id, 0) <> 0').destroy_all

    end
  end

  alias_method :upvotes_sum, :sum_upvotes

  private

  def reformat_uniqueness_validation
    if errors[:hash_key]
      errors[:base].concat(errors.delete(:hash_key))
    end
  end
end
