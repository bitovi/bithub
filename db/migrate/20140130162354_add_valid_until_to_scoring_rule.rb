class AddValidUntilToScoringRule < ActiveRecord::Migration
  def change
    change_table :scoring_rules do |t|
      t.datetime :valid_until
    end
  end
end
