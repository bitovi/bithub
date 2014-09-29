class DropFunnels < ActiveRecord::Migration
  def change
    drop_table :funnels
  end
end
