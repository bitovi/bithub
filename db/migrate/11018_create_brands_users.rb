class CreateBrandsUsers < ActiveRecord::Migration
  def change
    create_table :brands_users, :id => false do |t|
      t.belongs_to :user
      t.belongs_to :brand
    end
  end
end
