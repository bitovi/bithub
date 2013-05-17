require 'digest/md5'

class User < ActiveRecord::Base
  rolify
  devise :rememberable, :trackable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :address, :city, :email, :name, :postal, :email, :remember_me, :state, :country
  serialize :props, ActiveRecord::Coders::Hstore

  belongs_to :country
  has_many :anteups_as_actor, :foreign_key => "actor_id", :class_name => "Anteup", :dependent => :destroy
  has_many :upvotes_as_actor, :foreign_key => "actor_id", :class_name => "Upvote", :dependent => :destroy
  has_many :awards_as_actor, :foreign_key => "actor_id", :class_name => "Award", :dependent => :destroy
  has_many :events, :foreign_key => "author_id", :class_name => "Event"
  has_many :internals, :foreign_key => "receiver_id"
  has_many :anteups, :through => :events
  has_many :upvotes, :through => :events
  has_many :awards, :through => :events
  has_many :identities, :dependent => :destroy
  
  before_save :calculate_gravatar_hash

  def activities
    self.events.joins(:rule).select(['events.id','events.title', 'events.created_at', 'rules.authorship_value'])
    .concat(self.upvotes.includes(:applies_to).select(['upvotes.*', 'events.title']))
    .concat(self.awards.includes(:applies_to).select(['awards.*', 'events.title']))
    .concat(self.anteups.includes(:applies_to).select(['anteups.*', 'events.title']))
    .concat(self.internals.includes(:applies_to).select(['internals.*']))
    .sort {|x, y| x[:created_at] <=> y[:created_at]}
  end

  def self.select_with_score(include_users=true)
    query_string = <<-SQL
    (
      (select coalesce(sum(rules.authorship_value),0) from events, rules
      where events.rule_id = rules.id
      and events.author_id = users.id)
      +
      (select coalesce(sum(upvotes.value),0) from events, upvotes
      where upvotes.applies_to_id = events.id
      and events.author_id = users.id)
      +
      (select coalesce(sum(awards.value),0) from events, awards
      where awards.applies_to_id = events.id
      and events.author_id = users.id)
      +
      (select coalesce(sum(internals.value),0) from internals
      where internals.receiver_id = users.id)
      -
      (select coalesce(sum(anteups.value),0) from anteups
      where anteups.actor_id = users.id
      and anteups.fullfilled = true)
    ) as total_score
    SQL
    query_string = "users.*, " + query_string if include_users
    select(query_string)
  end
  
  def score
    self.authored_events_total + self.upvotes_total + self.awards_total + self.internals_total - self.fulfilled_anteups_total
  end

  def authored_events_total
    self.events.reduce(0) { |acc, ev| acc + ev.rule.authorship_value }
  end

  def upvotes_total
    self.upvotes.sum('value')
  end

  def awards_total
    self.awards.sum('value')
  end

  def internals_total
    self.internals.sum('value')
  end

  def fulfilled_anteups_total
    self.anteups_as_actor.fullfilled.sum('value')
  end

  def collect_authored_events
    identities.each do |ident|
      events = Event.where("props -> 'origin_author_id' = :uid", uid: ident.uid.to_s)
      if events
        events.each do |event|
          event.update_attribute(:author_id, self.id)
        end
      end
    end
  end

  def update_blank_oauth_attrs!(args)
    self.name = args[:name] if self.name.blank? && !args[:name].blank?
    self.email = args[:email] if self.email.blank? && !args[:email].blank?
    save! if self.changed?
  end

  def merge_identities!(identity)
    other_user = identity.user if identity.user
    if !self.identities.include?(identity)
      self.identities << identity 
      other_user.destroy if self.save && other_user
    end
  end

  private
  def calculate_gravatar_hash
    if email
      self.props[:gravatar_url] = "https://gravatar.com/avatar/#{Digest::MD5.hexdigest(self.email)}"
    end
  end

  def self.has_an_attribute?(attr)
    User.reflections.include?(attr) ||
    User.reflections.include?(attr.to_s.pluralize.to_sym) ||
    User.attribute_names.include?(attr) ||
    User.attribute_names.include?(attr.to_s.pluralize.to_sym)
  end
end
