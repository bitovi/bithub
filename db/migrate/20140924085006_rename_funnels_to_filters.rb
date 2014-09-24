class RenameFunnelsToFilters < ActiveRecord::Migration
  def change
    rename_table :funnels, :filters
  end
end
