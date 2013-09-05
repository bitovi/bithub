class RenameAchivementFields < ActiveRecord::Migration
  def up
    change_table :achievements do |t|
      t.rename :achieved, :achieved_at
      t.rename :shipped, :shipped_at
    end
  end

  def down
    change_table :achievements do |t|
      t.rename :achieved_at, :achieved
      t.rename :shipped_at, :shipped
    end
  end
end
