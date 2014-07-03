class CreateScoringRules < ActiveRecord::Migration
  def change
    create_table :scoring_rules do |t|
      t.string  :name
      t.hstore  :required_tags

      t.integer :authorship_value, :default => 0
      t.integer :award_value, :default => 0
      t.integer :upvote_value, :default => 0

      t.hstore  :props, default: ''
      t.integer :position

      t.datetime :valid_until

      t.timestamps
    end
  end
end
