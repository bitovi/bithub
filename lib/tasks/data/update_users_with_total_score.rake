namespace :data do
  desc "Updates total_score for all users."

  task :update_users_with_total_score => :environment do
    command = <<-SQL
      UPDATE users SET total_score = user_total_score.score_sum
      FROM user_total_score
      WHERE users.id = user_total_score.user_id;
    SQL

    puts "---"
    puts "Updating total_score (cached score) for all users"
    ActiveRecord::Base.connection.execute(command)
    puts "Cached score updated"
  end
end
