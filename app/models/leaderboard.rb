class Leaderboard < ActiveRecord::Base
  self.table_name = :leaderboard
  attr_accessible :score, :user_id, :user_name
end
