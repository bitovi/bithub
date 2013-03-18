class User < ActiveRecord::Base
  rolify
  devise :rememberable, :trackable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :address, :city, :email, :name, :postal, :email, :remember_me

  has_many :anteups, :foreign_key => "actor_id", :dependent => :destroy
  has_many :upvotes, :foreign_key => "actor_id", :dependent => :destroy
  has_many :internals, :foreign_key => "receiver_id", :autosave => true
  has_many :authored_events, :foreign_key => "author_id", :class_name => "Event"
  has_many :identities, :dependent => :destroy

  validates :email, :uniqueness => true
  
  # type, actor_id, applies_to, value, ts

  def sum_points
    sum = 0
    authored_events.each do |ev|
      sum += ev.rule.authorship_value             # authorships
          +  ev.upvotes.sum('value')              # upvotes
          +  ev.awards.sum('value')               # awards
          -  self.anteups.fullfilled.sum('value') # subtract fullfilled anteups
    end
    sum
  end

  def self.top(n=10)

    # calculate scores for all users
    scores = []
    all.each do |user|
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

end
