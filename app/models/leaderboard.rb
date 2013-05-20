class Leaderboard < ActiveRecord::Base
  set_table_name :leaderboard
  attr_accessible :score, :user_id, :user_name
end
