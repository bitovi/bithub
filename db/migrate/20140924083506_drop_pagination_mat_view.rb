class DropPaginationMatView < ActiveRecord::Migration
  def change
    execute "drop materialized view pagination;"
  end
end
