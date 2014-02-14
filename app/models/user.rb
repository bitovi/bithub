class User < ActiveRecord::Base

  class AsyncUserUpdater < Struct.new(:id, :method)
    def perform
      user = User.find_by_id(id)
      unless user.nil?
        user.send(method)
      end
    end
  end

  rolify
  devise :rememberable, :trackable, :omniauthable

  attr_accessible :address, :city,
    :email, :name, :postal, :email,
    :remember_me, :state, :country,
    :entities, :total_score

  serialize :props, ActiveRecord::Coders::Hstore

  has_many :anteups_as_actor, :foreign_key => "actor_id", :class_name => "Anteup", :dependent => :destroy
  has_many :upvotes_as_actor, :foreign_key => "actor_id", :class_name => "Upvote", :dependent => :destroy
  has_many :awards_as_actor, :foreign_key => "actor_id", :class_name => "Award", :dependent => :destroy
  has_many :internals_as_actor, :foreign_key => "actor_id", :class_name => "Internal", :dependent => :nullify

  has_many :ownerships, foreign_key: 'owner_id', :dependent => :destroy
  has_many :entities, through: :ownerships, source: 'entity'

  has_many :internals, :foreign_key => "receiver_id", :dependent => :destroy
  has_many :anteups, :through => :entities
  has_many :upvotes, :through => :entities
  has_many :awards, :through => :entities

  has_many :achievements, :dependent => :destroy
  has_many :rewards, :through => :achievements

  has_many :identities, :dependent => :nullify
  belongs_to :country

  scope :only_not_null_names, lambda { where("name <> '' and name IS NOT NULL") }

  after_update :award_points_for_completing_profile

  def activities
    activities = []

    self.entities.joins(:scoring_rule).all.each do |e|
      activities.push({:type => 'author', :id => e.id, :title => e.title, :value => e.scoring_rule.authorship_value, :upvotes => e.sum_upvotes, :created_at => e.created_at, origin_ts: (e.respond_to?(:origin_ts) ? e.origin_ts : nil)})
    end

    self.awards.select(['awards.*', 'entities.title']).all.each do |a|
      activities.push({:type => 'award', :id => a.id, :event_id => a.applies_to_id, :title => a.title, :value => a.value, :created_at => a.created_at, origin_ts: (a.respond_to?(:origin_ts) ? a.origin_ts : nil)})
    end

    self.upvotes.select(['upvotes.*', 'entities.title']).all.each do |u|
      activities.push({:type => 'upvote', :id => u.id, :title => u.title, :value => u.value, :created_at => u.created_at, origin_ts: (u.respond_to?(:origin_ts) ? u.origin_ts : nil)})
    end

    self.anteups.select(['anteups.*', 'entities.title']).all.each do |u|
      activities.push({:type => 'anteup', :id => u.id, :title => u.title, :value => u.value, :created_at => u.created_at, origin_ts: (u.respond_to?(:origin_ts) ? u.origin_ts : nil)})
    end

    self.internals.all.each do |i|
      activities.push({:type => 'internal', :id => i.id, :title => i.comment, :value => i.value, :created_at => i.created_at, origin_ts: (i.respond_to?(:origin_ts) ? i.origin_ts : nil)})
    end

    activities.sort {|x, y| 
      sort_x = x[:origin_ts] || x[:created_at]
      sort_y = y[:origin_ts] || y[:created_at]
      sort_x <=> sort_y
    }
  end

  def actions
    actions = []
    actions += self.awards_as_actor.all
    actions += self.upvotes_as_actor.all
    actions += self.anteups_as_actor.all
    actions += self.internals_as_actor.all
    actions
  end

  def score
    authored_entities_total + upvotes_total + awards_total + internals_total - fulfilled_anteups_total
  end

  def authored_entities_total
    ownerships.sum(:value)
  end

  def upvotes_total
    upvotes.sum(:value)
  end

  def awards_total
    awards.sum(:value)
  end

  def internals_total
    internals.sum(:value)
  end

  def fulfilled_anteups_total
    anteups_as_actor.fullfilled.sum('value')
  end

  def collect_authored_entities
    identities.each do |ident|
      Entity.origin_author(ident.uid).find_each do |entity|
        entity.author = self # TODO better way of changing owners?
      end
    end
  end

  def update_total_score
    update_attribute(:total_score, self.score)
  end

  def comleted_profile?
    Users::PointAwarder.new(self).completed_profile?
  end

  def award_points_for_completing_profile
    Users::PointAwarder.new(self).award_points_for_completing_profile
  end

  def award_points_for_linking(provider)
    Users::PointAwarder.new(self).award_points_for_linking(provider)
  end

  def reward_if_eligible
    Users::RewardEligiblityDecider.new(user: self).reward_if_eligible
  end

  def unreward_if_uneligible
    Users::RewardEligiblityDecider.new(user: self).unreward_if_uneligible
  end
  
  def calculate_avatar_url
    props['avatar_url'] ||= Users::AvatarDecider.new(self).avatar_url
  end

  def async_collect_authored_entities
    Delayed::Job.enqueue AsyncUserUpdater.new(self.id, :collect_authored_entities)
  end

  def async_update_total_score
    Delayed::Job.enqueue AsyncUserUpdater.new(self.id, :update_total_score)
  end

  def async_reward_if_eligible
    Delayed::Job.enqueue AsyncUserUpdater.new(self.id, :reward_if_eligible)
  end

  def async_unreward_if_uneligible
    Delayed::Job.enqueue AsyncUserUpdater.new(self.id, :unreward_if_uneligible)
  end

  # Helpers
  def self.has_an_attribute?(attr)
    User.reflections.include?(attr) ||
    User.reflections.include?(attr.to_s.pluralize.to_sym) ||
    User.attribute_names.include?(attr) ||
    User.attribute_names.include?(attr.to_s.pluralize.to_sym)
  end
end
