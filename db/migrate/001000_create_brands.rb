class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.string :description
      t.string_array :keywords
      t.hstore :props

      t.timestamps
    end
  end
end
