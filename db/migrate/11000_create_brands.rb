class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.string :tenant_name
      t.hstore :props, default: ''

      t.timestamps
    end

    add_index :brands, :tenant_name, :unique => true
    add_index :brands, :name, :unique => true
  end
end
