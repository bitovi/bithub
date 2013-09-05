class CreateAchievements < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.belongs_to :user, :null => false
      t.belongs_to :reward, :null => false
      t.string :note
      t.timestamp :achieved
      t.timestamp :shipped
    end
  end
end
