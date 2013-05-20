class CreateLeaderboards < ActiveRecord::Migration
  def change
    create_table :leaderboard, :id => false do |t|
      t.integer :user_id
      t.string :user_name
      t.string :user_email
      t.string :user_gravatar_url
      t.integer :user_score
    end
  end
end
