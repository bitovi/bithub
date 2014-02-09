class User < ActiveRecord::Base
  class OtherUserAlreadyLinked < Exception; end

  rolify
  devise :rememberable, :trackable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :address, :city,
    :email, :name, :postal, :email,
    :remember_me, :state, :country,
    :entities, :total_score

  serialize :props, ActiveRecord::Coders::Hstore

  belongs_to :country

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

  has_many :identities, :dependent => :destroy

  has_many :achievements, :dependent => :destroy
  has_many :rewards, :through => :achievements

  before_save :calculate_avatar_url

  scope :only_not_null_names, lambda { where("name <> '' and name IS NOT NULL") }

  after_update :check_and_award_points_for_completing_profile

  def activities
    activities = []

    self.entities.joins(:scoring_rule).all.each do |e|
      activities.push({:type => 'author', :id => e.id, :title => e.title, :value => e.scoring_rule.authorship_value, :upvotes => e.sum_upvotes, :created_at => e.created_at})
    end

    self.awards.select(['awards.*', 'entities.title']).all.each do |a|
      activities.push({:type => 'award', :id => a.id, :event_id => a.applies_to_id, :title => a.title, :value => a.value, :created_at => a.created_at})
    end

    self.upvotes.select(['upvotes.*', 'entities.title']).all.each do |u|
      activities.push({:type => 'upvote', :id => u.id, :title => u.title, :value => u.value, :created_at => u.created_at})
    end

    self.anteups.select(['anteups.*', 'entities.title']).all.each do |u|
      activities.push({:type => 'anteup', :id => u.id, :title => u.title, :value => u.value, :created_at => u.created_at})
    end

    self.internals.all.each do |i|
      activities.push({:type => 'internal', :id => i.id, :title => i.comment, :value => i.value, :created_at => i.created_at})
    end

    activities.sort {|x, y| x[:created_at] <=> y[:created_at]}
  end

  def activities_raw
    activities = []
    activities += self.awards.all
    activities += self.upvotes.all
    activities += self.anteups.all
    activities += self.internals.all
    activities
  end

  def actions
    actions = []
    actions += self.awards_as_actor.all
    actions += self.upvotes_as_actor.all
    actions += self.anteups_as_actor.all
    actions += self.internals_as_actor.all
    actions
  end

  def cached_score
    Leaderboard.where(user_id: self.id).first.user_score || 0
  end

  def score
    self.authored_entities_total + self.upvotes_total + self.awards_total + self.internals_total - self.fulfilled_anteups_total
  end

  def authored_entities_total
    self.ownerships.sum(:value)
  end

  def upvotes_total
    self.upvotes.sum(:value)
  end

  def awards_total
    self.awards.sum(:value)
  end

  def internals_total
    self.internals.sum(:value)
  end

  def fulfilled_anteups_total
    self.anteups_as_actor.fullfilled.sum('value')
  end

  def collect_authored_entities
    identities.each do |ident|
      entities = Event.where("props -> 'origin_author_id' = :uid", uid: ident.uid.to_s)
      if entities
        entities.each do |event|
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

  def update_total_score
    self.update_attribute(:total_score, self.score)
  end

  def link_ident!(identity)
    other_user = identity.user
    if identity.already_linked_to_other_user?
      fail OtherUserAlreadyLinked
    elsif already_linked_to_current_user?(identity)
      self
    else
      self.identities << identity
      self.delay.snatch_all_and_destroy(other_user) if other_user
      self.save!
    end
  end

  def snatch_all_and_destroy(whom)
    self.snatch_entities_from(whom)
    self.snatch_actions_from(whom)
    self.snatch_internals_from(whom)
    self.update_total_score
    self.reward_if_eligible
    whom.destroy
  end

  def snatch_entities_from(whom)
    whom.ownerships.where(:ownership_type => :author).update_all(:owner_id => self)
  end

  def snatch_actions_from(whom)
    whom.awards_as_actor.update_all(:actor_id => self)
    whom.anteups_as_actor.update_all(:actor_id => self)
    whom.upvotes_as_actor.update_all(:actor_id => self)
    whom.internals_as_actor.update_all(:actor_id => self)
  end

  def snatch_internals_from(whom)
    whom.internals.update_all(:receiver_id => self)
  end

  def check_and_award_points_for_completing_profile
    if self.completed_profile? && !self.already_awarded_for_profile_completion?
      self.internals.create({receiver: self, value: 1, comment: "Completed profile."})
    end
    self
  end

  def award_points_for_linking(provider)
    self.internals.build({receiver: self, value: 1, comment: "Logged in with #{provider.capitalize}."})
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

  def only_one_ident?
    self.identities.count == 1
  end

  def reward_if_eligible
    if rs = Reward.find_all_qualified_for(self)
      not_already_achieved_rewards = Achievement.reject_achieved_rewards(self, rs)
      rewards << not_already_achieved_rewards
      save
    end
  end

  def validate_eligibility
    if rs = Reward.find_all_qualified_for(self)
      delete_uneligible_achievements if self.rewards.length > rs
    end
  end

  def already_linked_to_current_user?(identity)
    self.identities.include?(identity)
  end

  def delete_uneligible_achievements
    raise "NOT IMPLEMENTED"
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

      begin
        response = Net::HTTP.get_response(URI.parse(gravatar + '?d=404'))
        response.code == '200' ? gravatar : ''
      rescue
        return ''
      end
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
