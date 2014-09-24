class CreateFiltersNatlangQueries < ActiveRecord::Migration
  def change
    create_table :filters_natlang_queries, :id => false do |t|
      t.references :filter
      t.references :natlang_query
    end
  end
end
