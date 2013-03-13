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
    sum = 0
    authored_events.each do |ev|
      sum += ev.rule.authorship_value                        # authorships
          +  ev.activities.upvotes.sum('value')              # upvotes
          +  ev.activities.awards.sum('value')               # awards
          -  self.activities.fullfilled_stakes.sum('value')  # subtract fullfilled stakes
    end
    sum
  end

  def self.top(n=10)

    # calculate scores for all users
    scores = []
    all.each do |user|
      scores << {:id => user.id, :score => user.sum_points}
    end

    scores.each do |s|
      puts s
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

end
