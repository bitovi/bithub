class User < ActiveRecord::Base
  rolify
  devise :rememberable, :trackable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :address, :city, :email, :name, :postal, :email, :remember_me

  has_many :activities, :foreign_key => "actor_id", :dependent => :destroy
  has_many :authored_events, :foreign_key => "author_id", :class_name => "Event"
  has_many :identities, :dependent => :destroy

  validates :email, :uniqueness => true
  
  # Received awards
  has_many :awards, :finder_sql => proc {
    "SELECT a.* FROM events AS e activities AS a" +
    "WHERE e.id = a.applies_to_id" +
    "AND a.identificator = award" +
    "AND e.author_id = #{id}"
  }

  # Received upvotes
  has_many :upvotes, :finder_sql => proc {
    "SELECT a.* FROM events AS e activities AS a" +
    "WHERE e.id = a.applies_to_id" +
    "AND a.identificator = upvote" +
    "AND e.author_id = #{id}"
  }

  # Events that the user awarded
  has_many :events_awarded, :finder_sql => proc { 
    "SELECT e.* FROM events AS e activities AS a" +
    "WHERE e.id = a.applies_to_id" +
    "AND a.identificator = award" +
    "AND a.actor_id = #{id}"
  }  
   
  # Events that the user upvoted
  has_many :events_upvoted, :finder_sql => proc { 
    "SELECT e.* FROM events AS e, activities AS a" +
    "WHERE e.id = a.applies_to_id" +
    "AND a.identificator = upvote" +
    "AND a.actor_id = #{id}"
  }

  def sum_points
    authored_events.reduce do |ev|
      return ev.rule.authorship_value                           # authorships
             +  ev.activities.upvotes.sum('value')              # upvotes
             +  ev.activites.awards.sum('value')                # awards
             -  self.activities.fullfiled_stakes.sum('value')   # subtract fullfilled stakes
    end
  end

  def self.top(n=10)
  end

end
