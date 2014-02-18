class UserActivity < ActiveRecord::Base
  self.table_name = :user_activities

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW \"#{self.table_name}\";")
  end

end
