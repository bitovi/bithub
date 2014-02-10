class CreateApiCache < ActiveRecord::Migration
  def change
    create_table :api_cache do |t|
      t.string :provider
      t.string :name
      t.string :uid
    end

    add_index(:api_cache, [:uid, :provider])
  end
end
