class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.string_array :required_tags
      t.integer :authorship_value
      t.integer :award_value
      t.integer :upvote_value
      t.integer :priority

      t.timestamps
    end
  end
end
