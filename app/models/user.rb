class User < ActiveRecord::Base
  rolify
  devise :rememberable, :trackable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :address, :city, :email, :name, :postal

  has_many :activities, :foreign_key => "actor_id", :dependent => :destroy
  has_many :authored_events, :foreign_key => "author_id", :class_name => "Event"
  has_many :identities

  validates :name, :email, :presence => true
  validates :email, :uniqueness => true
  
  # Received awards
  has_many :awards, :finder_sql => proc {
    "SELECT a.* FROM events AS e activities AS a" +
    "WHERE e.id = a.applies_to_id" +
    "AND a.type = award" +
    "AND e.author_id = #{id}"
  }

  # Received upvotes
  has_many :upvotes, :finder_sql => proc {
    "SELECT a.* FROM events AS e activities AS a" +
    "WHERE e.id = a.applies_to_id" +
    "AND a.type = upvote" +
    "AND e.author_id = #{id}"
  }

  # Events that the user awarded
  has_many :events_awarded, :finder_sql => proc { 
    "SELECT e.* FROM events AS e activities AS a" +
    "WHERE e.id = a.applies_to_id" +
    "AND a.type = award" +
    "AND a.actor_id = #{id}"
  }
  
  # Events that the user upvoted
  has_many :events_upvoted, :finder_sql => proc { 
    "SELECT e.* FROM events AS e, activities AS a" +
    "WHERE e.id = a.applies_to_id" +
    "AND a.type = upvote" +
    "AND a.actor_id = #{id}"
  }

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
