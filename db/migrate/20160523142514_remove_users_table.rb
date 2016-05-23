class RemoveUsersTable < ActiveRecord::Migration
	def up
		drop_table :users
		drop_table :brands_users
	end
	
	def down
		create_table :users do |t|
			t.string  :name
			t.string  :email
			t.string  :address
			t.string  :address2
			t.string  :city
			t.string  :postal
			t.string  :state
			t.hstore  :props, default: ''
			t.integer :total_score, default: 0

			t.references :country

			t.timestamps
		end
		add_index :users, :email
		
		create_table :brands_users do |t|
			t.belongs_to :user
			t.belongs_to :brand
			t.integer    :total_score, default: 0
			t.hstore     :props, default: ''
		end
	end
end
