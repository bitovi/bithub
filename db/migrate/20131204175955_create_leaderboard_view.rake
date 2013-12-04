class CreateLeaderboardView < ActiveRecord::Migration
  def up
    execute <<-SQL
      create materialized view leaderboard
      as
      ...
    SQL
  end

  def down
    execute <<-SQL
      drop materialized view leaderboard;
    SQL
  end
end

