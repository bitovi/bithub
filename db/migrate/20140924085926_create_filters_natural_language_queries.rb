class CreateFiltersNaturalLanguageQueries < ActiveRecord::Migration
  def change
    create_table :filters_natural_language_queries, :id => false do |t|
      t.references :filter
      t.references :natural_language_query
    end
  end
end
