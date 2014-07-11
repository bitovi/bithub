class User < ActiveRecord::Base
  extend Solipsism

  store_accessor :props

  rolify :role_cname => 'UserRole'
  devise :rememberable, :trackable, :omniauthable

  has_many :upvotes_as_actor, :foreign_key => "actor_id", :class_name => "Upvote", :dependent => :destroy
  has_many :awards_as_actor, :foreign_key => "actor_id", :class_name => "Award", :dependent => :destroy
  has_many :internals_as_actor, :foreign_key => "actor_id", :class_name => "Internal", :dependent => :nullify

  has_many :ownerships, foreign_key: 'owner_id', :dependent => :destroy
  has_many :entities, through: :ownerships, source: 'entity'

  has_many :activities, :foreign_key => "user_id", :class_name => "UserActivity"

  has_many :internals, :foreign_key => "receiver_id", :dependent => :destroy
  has_many :upvotes, :through => :entities
  has_many :awards, :through => :entities

  has_many :achievements, :dependent => :destroy
  has_many :rewards, :through => :achievements

  has_many :identities, :dependent => :nullify
  belongs_to :country

  scope :only_not_null_names, lambda { where("name <> '' and name IS NOT NULL") }

  before_save :calculate_avatar_url
  after_save :award_points_for_completing_profile

  def actions
    actions = []
    actions += self.awards_as_actor.all
    actions += self.upvotes_as_actor.all
    actions += self.internals_as_actor.all
    actions
  end

  def score
    authored_entities_total + upvotes_total + awards_total + internals_total
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

  def collect_authored_entities
    identities.each do |ident|
      Entity.origin_author(ident.uid).find_each do |entity|
        entity.author = self # TODO better way of changing owners?
      end
    end
  end

  def collect_hosted_entities
    if (ident = identities.where(provider: 'meetup').first)
      Entity.feed('meetup').type('event').origin_host(ident.uid).find_each do |entity|
        entity.ownerships << Ownership.new(owner: self, entity: entity, ownership_type: :host).determine_value
        entity.save
      end
    end
  end

  def update_total_score
    update_attribute(:total_score, self.score)
  end

  def update_blank_attrs(ident)
    self.name = ident.name if self.name.blank? && ident.name.present?
    self.email = ident.email if self.email.blank? && ident.email.present?
  end

  def comleted_profile?
    Users::PointAwarder.new(self).completed_profile?
  end

  def award_points_for_completing_profile
    Users::PointAwarder.new(self).award_points_for_completing_profile
  end

  def award_points_for_linking(ident)
    Users::PointAwarder.new(self).award_points_for_linking(ident.provider)
  end

  def reward_if_eligible
    Users::Rewarder.new(user: self).reward_if_eligible
  end

  def unreward_if_uneligible
    Users::Rewarder.new(user: self).unreward_if_uneligible
  end

  def calculate_avatar_url
    props['avatar_url'] = Users::AvatarCalculator.new(self).execute
  end

  def async_collect_authored_entities
    Workers::UserUpdater.perform_async self.id, :collect_authored_entities
    Workers::UserUpdater.perform_async self.id, :collect_hosted_entities
  end

  def async_update_total_score
    Workers::UserUpdater.perform_async self.id, :update_total_score
  end

  def async_reward_if_eligible
    Workers::UserUpdater.perform_async self.id, :reward_if_eligible
  end

  def async_unreward_if_uneligible
    Workers::UserUpdater.perform_async self.id, :unreward_if_uneligible
  end

  def join_brand(brand)
    if brand = match_brand(brand)
      update_column :brand_ids, brand_ids.push(brand.id) unless brand_ids.include? brand.id
    end

    self
  end

  def remove_brand(brand)
    if brand = match_brand(brand)
      if brand_ids.delete(brand.id)
        update_column :brand_ids, brand_ids
      end
    end

    self
  end

  private

  def match_brand(brand)
    if brand.is_a? Integer
      Brand.find_by_id(brand)
    elsif brand.is_a? String or brand.is_a? Symbol
      Brand.where(:name => brand.to_s).first
    elsif brand.is_a? Brand
      brand
    end
  end

end
