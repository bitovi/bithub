class AddBrandReferenceToFeedConfig < ActiveRecord::Migration
  def change
    add_column :feed_configs, :brand_id, :integer
    remove_column :feed_configs, :brand_name
  end
end
