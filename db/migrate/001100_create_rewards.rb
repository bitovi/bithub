class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.string   :title
      t.text     :description
      t.integer  :point_minimum
      t.string   :image
      t.datetime :disabled_ts
      t.hstore   :props

      t.timestamps
    end
  end
end
