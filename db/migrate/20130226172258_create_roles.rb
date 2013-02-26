class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.integer :level
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
