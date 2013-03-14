class User < ActiveRecord::Base
  rolify
  devise :rememberable, :trackable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :address, :city, :email, :name, :postal, :email, :remember_me

  has_many :anteups, :foreign_key => "actor_id", :dependent => :destroy, :class_name => "Anteup"
  has_many :upvotes, :foreign_key => "actor_id", :dependent => :destroy, :class_name => "Upvote"
  has_many :authored_events, :foreign_key => "author_id", :class_name => "Event"
  has_many :identities, :dependent => :destroy

  validates :email, :uniqueness => true
  
  # type, actor_id, applies_to, value, ts
  has_many :activities, :finder_sql => proc { <<-SQL
    SELECT 
       'authorship' AS type,
        events.id AS event_id,
        events.title AS event_title,
        rules.authorship_value + (SELECT SUM(value) FROM upvotes WHERE upvotes.applies_to_id=events.id) AS value, 
        events.origin_ts AS ts
      FROM events 
        LEFT JOIN rules ON events.rule_id=rules.id
        LEFT JOIN upvotes ON upvotes.applies_to_id=events.id
        WHERE events.author_id=#{id}
    UNION
    SELECT 
        'award' AS type, 
        awards.applies_to_id AS event_id,
        events.title AS event_title, 
        awards.value AS value,
        awards.updated_at AS ts
      FROM awards
        LEFT JOIN events ON events.id=awards.applies_to_id
        WHERE events.author_id=#{id}
    UNION
    SELECT 
        'anteup' AS type, 
        anteups.applies_to_id,
        events.title AS event_title,
        anteups.value AS value,
        anteups.updated_at AS ts
      FROM anteups 
        LEFT JOIN events ON events.id=anteups.applies_to_id
        WHERE anteups.actor_id=#{id} AND fullfilled='t'
    UNION
    SELECT 
        'internal' AS type,
        NULL,
        NULL,
        value AS value,
        updated_at AS ts
      FROM internal WHERE receiver_id=#{id}
    ORDER BY ts DESC;
  SQL
  }

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
