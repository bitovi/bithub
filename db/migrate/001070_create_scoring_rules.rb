class CreateScoringRules < ActiveRecord::Migration
  def change
    create_table :scoring_rules do |t|
      t.string       :name
      t.string_array :required_tags
      t.integer      :authorship_value
      t.integer      :award_value
      t.integer      :upvote_value
      t.integer      :priority
      t.datetime     :valid_until

      t.timestamps
    end
  end
end
