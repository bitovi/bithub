class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.string :feed
      t.string :type
      t.string :state
      t.string :label
      t.string :catgory
      t.integer :points
      t.integer :award

      t.timestamps
    end
  end
end
