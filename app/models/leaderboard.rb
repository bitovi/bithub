class Leaderboard < ActiveRecord::Base
  self.table_name = :leaderboard

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW \"#{self.table_name}\";")
  end
end
