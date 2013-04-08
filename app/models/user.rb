require 'digest/md5'

class User < ActiveRecord::Base
  rolify
  devise :rememberable, :trackable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :address, :city, :email, :name, :postal, :email, :remember_me
  serialize :props, ActiveRecord::Coders::Hstore

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
    activities = []
    activities.concat(self.awards)
    activities.concat(self.upvotes)
    activities.concat(self.anteups)
    activities.concat(self.internals)
    activities.sort {|x, y| x.origin_ts <=> y.origin_ts}
  end

  def score
    sum_points
  end

  def sum_points
    sum = 0
    self.events.each do |ev|
      sum += ev.rule.authorship_value + ev.upvotes.sum('value') + ev.awards.sum('value')
    end
    sum + self.internals.sum('value') - self.anteups.fullfilled.sum('value')
  end

  def avatar
    props['gravatar_url'] || '/assets/images/icon-user.png'
  end

  def self.top(n=10)
    users = self.all
    n = users.count if users.count < n

    # calculate scores for all users
    scores = []
    users.each do |user|
      scores << {:id => user.id, :score => user.sum_points}
    end

    # sort scores by score
    scores.sort_by{|s| -s[:score]}.reverse

    # get top n users
    top_users = []
    
    (0..n-1).each do |i|
      top_users << self.find(scores[i][:id])
    end

    top_users 
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
