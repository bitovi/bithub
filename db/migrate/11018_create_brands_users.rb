class CreateBrandsUsers < ActiveRecord::Migration
  def change
    create_table :brands_users, :id => false do |t|
      t.belongs_to :user
      t.belongs_to :brand
      t.integer    :total_score, default: 0
      t.hstore     :props, default: ''
    end
  end
end
