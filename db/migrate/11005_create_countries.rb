class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name, :null => false
      t.string :display_name
      t.string :iso, :null => false
      t.integer :priority, :default => 0
    end
  end
end
