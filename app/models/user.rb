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

  def sum_points_sql # temp
    query = %{
      SELECT rules.authorship_value + SUM(acts_add.value) - SUM(acts_sub.value) AS sum
        FROM users
          LEFT JOIN events
            ON events.author_id=#{id}
          LEFT JOIN rules 
            ON events.rule_id=rules.id
          LEFT JOIN activities AS acts_add 
            ON acts_add.applies_to_id=events.id AND acts_add.fullfilled=true AND acts_add.identificator != ANY('{4}')
          LEFT JOIN activities AS acts_sub 
            ON acts_sub.actor_id=#{id} AND acts_sub.fullfilled=true AND acts_sub.identificator = ANY('{4}')
          WHERE users.id=#{id}
          GROUP BY events.id, rules.authorship_value
    }

    result = ActiveRecord::Base.connection.execute(query).first['sum'].to_
  end

  def self.top(n=10)
  end

end
