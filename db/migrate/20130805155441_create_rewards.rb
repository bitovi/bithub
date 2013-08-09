class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.string  :title
      t.text    :description
      t.integer :point_minimum

      t.timestamps
    end
  end
end
