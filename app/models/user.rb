require 'digest/md5'

class User < ActiveRecord::Base
  rolify
  devise :rememberable, :trackable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :address, :city,
    :email, :name, :postal, :email,
    :remember_me, :state, :country,
    :events, :total_score

  serialize :props, ActiveRecord::Coders::Hstore

  belongs_to :country
  has_many :anteups_as_actor, :foreign_key => "actor_id", :class_name => "Anteup", :dependent => :destroy
  has_many :upvotes_as_actor, :foreign_key => "actor_id", :class_name => "Upvote", :dependent => :destroy
  has_many :awards_as_actor, :foreign_key => "actor_id", :class_name => "Award", :dependent => :destroy
  has_many :internals_as_actor, :foreign_key => "actor_id", :class_name => "Internal", :dependent => :nullify

  has_many :events, :foreign_key => "author_id", :class_name => "Event", :dependent => :nullify
  has_many :internals, :foreign_key => "receiver_id", :dependent => :destroy

  has_many :anteups, :through => :events
  has_many :upvotes, :through => :events
  has_many :awards, :through => :events

  has_many :identities, :dependent => :destroy
  
  has_many :achievements, :dependent => :destroy
  has_many :rewards, :through => :achievements

  before_save :calculate_avatar_url

  scope :only_not_null_names, lambda { where("name <> '' and name IS NOT NULL") }
  
  after_update :award_points_for_completing_profile

  def activities
    activities = []

    self.events.joins(:rule).each do |e|
      activities.push({:type => 'author', :id => e.id, :title => e.title, :value => e.rule.authorship_value, :upvotes => e.sum_upvotes, :created_at => e.created_at})
    end

    self.awards.select(['awards.*', 'events.title']).each do |a|
      activities.push({:type => 'award', :id => a.id, :event_id => a.applies_to_id, :title => a.title, :value => a.value, :created_at => a.created_at})  
    end

    self.upvotes.select(['upvotes.*', 'events.title']).each do |u|
      activities.push({:type => 'upvote', :id => u.id, :title => u.title, :value => u.value, :created_at => u.created_at})
    end

    self.internals.all.each do |i|
      activities.push({:type => 'internal', :id => i.id, :title => i.comment, :value => i.value, :created_at => i.created_at})
    end

    activities.sort {|x, y| x[:created_at] <=> y[:created_at]}
  end

  def cached_score
    Leaderboard.where(user_id: self.id).first.user_score || 0
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
    self
  end

  def update_blank_oauth_attrs!(args)
    self.name = args[:name] if self.name.blank? && !args[:name].blank?
    self.email = args[:email] if self.email.blank? && !args[:email].blank?
    save! if self.changed?
  end

  def merge_identities!(identity)
    other_user = identity.user if identity.user
    unless self.identities.include?(identity)
      self.identities << identity 
      self.save!
      other_user.destroy if other_user
    end
  end

  def award_points_for_completing_profile
    if self.completed_profile? && !self.already_awarded_for_profile_completion?
      self.internals.create({receiver: self, value: 1, comment: "Completed profile."})
    end
    self
  end

  def award_points_for_joining(provider)
    self.internals.build({receiver: self, value: 1, comment: "Logged in with #{provider}."})
    self
  end

  def already_awarded_for_profile_completion?
    Internal.where("receiver_id = ? AND comment = ?", self.id, "Completed profile.").present?
  end

  def completed_profile?
    self.name.present? &&
    self.email.present? &&
    self.address.present? &&
    self.city.present? &&
    self.postal.present? &&
    self.country.present?
  end

  def reward_if_eligible
    if rs = Reward.find_all_qualified_for(self)
      not_already_achieved_rewards = Achievement.reject_achieved_rewards(self, rs)
      rewards << not_already_achieved_rewards
      save
    end
  end

  def calculate_avatar_url
    url = '/assets/images/icon-user.png'

    image_attrs = ['avatar_url', 'profile_image_url']
    self.identities.each do |ident|
      image_attrs.each {|attr| url = ident['source_data'][attr] if ident['source_data'] && ident['source_data'][attr] }
    end

    gravatar_url = does_gravatar_exists?
    url = gravatar_url if not gravatar_url.blank?

    self.props['avatar_url'] = url
  end
  private

  def does_gravatar_exists?
    if !self.email.blank?
      gravatar = "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(self.email)}"

      # skip making HTTP request in tests
      return gravatar if Rails.env == "test"

      response = Net::HTTP.get_response(URI.parse(gravatar + '?d=404'))
      response.code == '200' ? gravatar : ''
    else
      ''
    end
  end

  def self.has_an_attribute?(attr)
    User.reflections.include?(attr) ||
    User.reflections.include?(attr.to_s.pluralize.to_sym) ||
    User.attribute_names.include?(attr) ||
    User.attribute_names.include?(attr.to_s.pluralize.to_sym)
  end
end
