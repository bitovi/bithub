class AlterRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :display_point_minimum, :string, default: ""
    add_column :rewards, :disabled_ts, :datetime
  end
end
