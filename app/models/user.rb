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
  validates :email, :uniqueness => true
  
  before_save :calculate_gravatar_hash

  def activities

    # fetch from DB
    events = self.events.joins(:rule).select(['events.id','events.title', 'events.created_at', 'rules.authorship_value'])
    upvotes = self.upvotes.includes(:applies_to).select(['upvotes.*', 'events.title'])
    awards = self.awards.includes(:applies_to).select(['awards.*', 'events.title'])
    anteups = self.anteups.includes(:applies_to).select(['anteups.*', 'events.title'])
    internals = self.internals.includes(:applies_to).select(['internals.*'])

    # merge and decorate
    activities = []
    activities.concat( events.map {|e| e.attributes.merge({:type => "authored", :value => e[:authorship_value]}) } )
    activities.concat( awards.map {|e| e.attributes.merge({:type => "awarded"}) } )
    activities.concat( upvotes.map {|e| e.attributes.merge({:type => "upvoted"}) } )
    activities.concat( anteups.map {|e| e.attributes.merge({:type => "anteup"}) } )
    activities.concat( internals.map {|e| e.attributes.merge({:type => "internal", :title => e[:comment]}) } )

    # return sorted
    activities.sort {|x, y| x[:created_at] <=> y[:created_at]}
  end
  
  def score
    self.events.reduce(0) { |acc, ev| acc + ev.rule.authorship_value }
    + self.upvotes.sum('value')
    + self.awards.sum('value')
    + self.internals.sum('value')
    - self.anteups.fullfilled.sum('value')
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

  def update_blank_oauth_attrs(args)
    self.name = args[:name] if self.name.blank? && !args[:name].blank?
    self.email = args[:email] if self.email.blank? && !args[:email].blank?
    save! if self.changed?
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
