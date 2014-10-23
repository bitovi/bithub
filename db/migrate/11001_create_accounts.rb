class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.hstore :props, default: ''

      t.timestamps
    end

    create_join_table :brands, :accounts do |t|
      t.index [:account_id, :brand_id]
      t.index [:brand_id, :account_id]
    end
  end
end
