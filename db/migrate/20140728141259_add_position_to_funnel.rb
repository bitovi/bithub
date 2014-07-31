class AddPositionToFunnel < ActiveRecord::Migration
  def change
    add_column :funnels, :position, :integer
  end
end
