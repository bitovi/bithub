class Entity < ActiveRecord::Base
  extend Solipsism
  include Traits::AmqpDeclaration

  serialize :props, IndifferentHstore

  def props=(hash)
    write_attribute :props, HashWithIndifferentAccess.new(hash)
  end

  acts_as_taggable

  has_many :events

  has_many :embed_entities, dependent: :destroy
  has_many :embeds, through: :embed_entities

  has_many :service_entities, dependent: :destroy
  has_many :services, through: :service_entities

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
  before_save :assign_searchable_attributes
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

  after_validation :reformat_uniqueness_validation

  def state
    props.andand['state']
  end

  def memoize(*args, &block)
    key = args.join('.')
    @_memoized ||= {}
    @_memoized[key] ||= yield
  end

  def has_only_one_service?
    services.count == 1
  end

  def is_approved(embed = nil)
    # Used when entities are decorated with attributes from embed_entities,
    # ie. is_approved_manually and is_approved_automatically
    if has_attribute?(:is_approved_manually) && has_attribute?(:is_approved_automatically)
      (read_attribute(:is_approved_manually) != nil) ? is_approved_manually? : is_approved_automatically?
    # If entity doesn't have these attributes (is_approved_*), then given an embed,
    # find the appropriate embed_entities record and read that info from it
    else
      return nil if embed.nil?
      memoize('is_approved', embed.id) do
        embed_entities.find_by_embed_id(embed.id).is_approved
      end
    end
  end

  # See first 5 lines of EmbedEntitiesController#build_scope method
  def is_pinned(embed = nil)
    if has_attribute?(:is_pinned)
      read_attribute(:is_pinned)
    else
      return nil if embed.nil?
      memoize('is_pinned', embed.id) do
        embed_entities.where(:embed_id => embed.id).first.is_pinned?
      end
    end
  end

  def is_child?
    !parent_id.nil?
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

  def assign_searchable_attributes
    assign_attributes({
      searchable_content: sanitized_content,
      searchable_title: sanitized_title,
      searchable_body: sanitized_body,
    })
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

  def sanitized_content
    [sanitized_title, sanitized_body, url, feed_name, type_name, image, cached_tag_list].join(' ')
  end

  def sanitized_title
    Sanitize.fragment(self.title, Sanitize::Config::RESTRICTED).strip
  end

  def sanitized_body
    Sanitize.fragment(self.body, Sanitize::Config::RESTRICTED).strip
  end

  def deserialize
    Entities::Dispatcher.dispatch(self.last_modified_by.deserialize)
  end

  def wrapped
    wrapper_class.new(last_modified_by.wrapped)
  end

  # private

  def reformat_uniqueness_validation
    if errors[:hash_key]
      errors[:base].concat(errors.delete(:hash_key))
    end
  end

  def notify_liveservice
    return if (is_pending? || is_child?)

    embeds.each do |embed|
      message = JSON.generate msg(embed)
      x('x.liveservice').publish(message, routing_key: 'entities')
      if !is_approved(embed)
        # if the entity is not approved we don't want to send publicly
        # the whole entity, but we need to send just enough so it can
        # be removed from an active embed. This way live embeds (like on
        # event media walls) can be moderated and updated
        x('x.liveservice').publish(JSON.generate(not_approved_msg(embed)), routing_key: 'entities')
      end
    end
  end

  def meta_msg(embed, is_public)
    {
      brand_name: Apartment::Tenant.current,
      embed_id: embed.id,
      is_public: is_public
    }
  end

  def not_approved_msg(embed)
    {
      meta: meta_msg(embed, true),
      payload: JSON.generate({
        id: self.id,
        is_approved: false
      })
    }
  end

  def msg(embed)
    view = ActionView::Base.new('app/views', {}, ActionController::Base.new)
    entity = EntityDecorator.decorate(self, context: {embed: embed})
    payload = view.render('api/v3/embed_entities/entity', {entity: entity, skip_caching: true})

    {
      meta: meta_msg(embed, is_approved(embed)),
      payload: payload
    }
  end

  def wrapper_class
    fn = feed_name.camelize.to_sym; tn = type_name.camelize.to_sym
    if ::Entities.constants.include?(fn) && ::Entities.const_get(fn).constants.include?(tn)
      ::Entities.const_get(fn).const_get(tn)
    end
  end
end
