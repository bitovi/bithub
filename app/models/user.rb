class User < ActiveRecord::Base
  rolify
  devise :rememberable, :trackable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :address, :city, :email, :name, :postal
  attr_accessible :provider, :uid

  has_many :activities, :foreign_key => "actor_id", :dependent => :destroy
  has_many :authored_events, :foreign_key => "author_id", :class => "Event"
  
  has_many :awarded_events, :finder_sql => proc { 
    "SELECT * FROM users AS u, events AS e activities AS a" +
    "WHERE u.id = e.author_id" +
    "AND e.id = a.applies_to_id" +
    "AND a.type = award" +
    "AND u.id = #{id}"
  }
  
  has_many :upvoted_events, :finder_sql => proc { 
    "SELECT * FROM users AS u, events AS e, activities AS a" +
    "WHERE u.id = e.author_id" +
    "AND e.id = a.applies_to_id" +
    "AND a.type = award" +
    "AND u.id = #{id}"
  }

  has_many :upvoted_events, :through => :activities, :source => :events,
    :conditions => ["activity.type = ?", 'upvote']

  def self.find_or_create(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if not user
      user = User.create(name:auth.extra.raw_info.name, provider:auth.provider, uid:auth.uid, email:auth.info.email)
    end
    user
  end

  def self.new_with_session(params, session)
    Rails.logger.info "SESSION: #{session["devise.twitter_data"]}"

    super.tap do |user|
      if data = session["devise.twitter_data"] && session["devise.twitter_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

end
