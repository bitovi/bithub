class Entity < ActiveRecord::Base
  extend Solipsism

  store_accessor :props

  acts_as_taggable

  has_many :events

  has_many :embed_entities, dependent: :destroy
  has_many :embeds, through: :embed_entities
  has_and_belongs_to_many :services

  has_many :ownerships, foreign_key: :entity_id, dependent: :destroy
  has_many :owners, through: :ownerships, source: :owner
  has_many :hosts, through: :ownerships, source: :host

  belongs_to :parent, :class_name => "Entity"
  has_many :children, :foreign_key => "parent_id", :class_name => "Entity"

  validates_presence_of  :title,
    :feed_name, :type_name,
    :origin_ts, :thread_updated_ts,
    :tag_list

  # Hooks
  after_commit :notify_liveservice

  # Basic
  scope :feed, ->(f) { where(feed_name: f) }
  scope :no_feed, ->(f) { where('feed_name <> ?', f) }
  scope :type, ->(t) { where(type_name: t) }
  scope :no_type, ->(t) { where('type_name <> ?', t) }

  scope :without_future, ->(client_tz) do
    where("thread_updated_ts AT TIME ZONE 'UTC' AT TIME ZONE ? < date_trunc('day', now() AT TIME ZONE ?) + interval '1 day'", client_tz, client_tz)
  end

  scope :in_future, ->(client_tz) do
    where("thread_updated_ts AT TIME ZONE 'UTC' AT TIME ZONE ? > date_trunc('day', now() AT TIME ZONE ?)", client_tz, client_tz)
  end

  # Thread belonging
  scope :belong_to_a_thread, -> do
    where 'parent_id IS NOT NULL OR id IN (SELECT parent_id from entities)'
  end

  scope :have_no_thread, -> do
    where 'parent_id IS NULL AND id NOT IN (SELECT parent_id from entities)'
  end

  # Parent/child
  scope :only_parents, -> { where('id IN (SELECT parent_id from entities WHERE parent_id IS NOT NULL)') }
  scope :only_children, -> { where('parent_id IS NOT NULL') }
  scope :no_parents, -> { where('id NOT IN (SELECT parent_id FROM entities WHERE parent_id IS NOT NULL)') }
  scope :no_children, -> { where('parent_id IS NULL') }

  # Authorship
  scope :origin_author, lambda {|uid| where("props -> 'origin_author_id' = :uid", uid: uid.to_s) }
  scope :origin_host, lambda {|uid| where("string_to_array(props -> 'event_host_ids_csv', ',') @> string_to_array(:uid, ',') OR string_to_array(props -> 'event_host_ids', ',') @> string_to_array(:uid, ',')", uid: uid.to_s) }

  # Issues
  scope :number, ->(n) { where("props ? 'number'").where("props -> 'number' = :val", val: n.to_s) }
  scope :repo_name, ->(rn) { where("props ? 'repo_name'").where("props -> 'repo_name' = :val", val: rn) }
  scope :with_state, ->(s) { where("props ? 'state'").where("props -> 'state' = :val", val: s) }

  scope :scoped_with_includes, -> { includes(:owners).includes(:parent) }

  after_validation :reformat_uniqueness_validation

  def self.satisfying(filter)
    NatlangQueries::Applier.new(filter, Entity).scope
  end

  def self.with_author(author_id)
    joins(:ownerships)\
      .where('ownerships.ownership_type = \'author\'')
      .where('ownerships.owner_id = ?', author_id) if author_id
  end

  def self.with_host(host_id)
    joins(:ownerships)\
      .where('ownerships.ownership_type = \'host\'')
      .where('ownerships.owner_id = ?', host_id) if host_id
  end

  def author=(user)
    remove_author
    ownerships << Ownership.new(owner: user, entity: self, ownership_type: :author)
  end

  def event_hosts=(users)
    remove_hosts
    users.each do |u|
      ownerships << Ownership.new(owner: u, entity: self, ownership_type: :host)
    end
  end

  def remove_author
    ownerships.where(ownership_type: :author).destroy_all
  end

  def remove_hosts
    ownerships.where(ownership_type: :host).destroy_all
  end

  def author
    ownerships.select(&:is_authorship?).first.andand.owner
  end

  def state
    props.andand['state']
  end

  def label_names
    props.andand['label_names']
  end

  def children_with_includes
    children.merge(Entity.scoped_with_includes)
  end

  def thread
    if parent_id # When an event is a child
      Entity.where('id = ? OR parent_id = ?', parent_id, parent_id)
    else # When an event is a parent
      Entity.where('id = ? OR parent_id = ?', id, id)
    end
  end

  def siblings
    parent.children
  end

  # FIXME, should be delegated to a proper type from Entities
  def bump_thread
    if feed_name == 'meetup' && type_name == 'event'
      latest_origin_ts = thread.pluck(:props)
        .map { |p| p['scheduled_at'] }
        .compact
        .map { |t| Time.parse t }.max
    else
      latest_origin_ts = thread.pluck(:origin_ts).max
    end
    thread.each { |te| te.update_thread_attrs(latest_origin_ts) }
  end

  def update_thread_attrs(ts)
    update_attribute(:thread_updated_ts, ts)
  end

  def latest_thread_ts
    thread.pluck(:origin_ts).max
  end

  def latest_child_ts
    children.order("origin_ts DESC").first.andand.origin_ts
  end

  def top_level_parent
    if parent
      parent.top_level_parent
    else
      self
    end
  end

  def cached_tags
    cached_tag_list.split(',').map { |t| t.strip }
  end

  def last_modified_by
    events.order('created_at DESC').first
  end

  def source_data
    last_modified_by.andand.source_data
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

  def deserialize
    Entities::Dispatcher.dispatch(self.last_modified_by.deserialize)
  end

  private

  def reformat_uniqueness_validation
    if errors[:hash_key]
      errors[:base].concat(errors.delete(:hash_key))
    end
  end

  def notify_liveservice
    view = ActionView::Base.new('app/views', {}, ActionController::Base.new)
    entity = EntityDecorator.decorate self

    payload = view.render('api/v3/embed_entities/entity', {entity: entity})

    embeds.each do |embed|
      Support::LiveserviceNotifier.new.notif({
        meta: {
          brand_name: Apartment::Database.current_tenant,
          embed_id: embed.id
        },
        payload: payload
      }, :entities)
    end
  end

end
