class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.string :description
      t.string :keywords, array: true, default: []
      t.hstore :props, default: ''

      t.timestamps
    end
  end
end
