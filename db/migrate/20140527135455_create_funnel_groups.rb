class CreateFunnelGroups < ActiveRecord::Migration
  def change
    create_table :funnel_groups do |t|
      t.string       :name
      t.string       :display_name
      t.string_array :tags
    end
  end
end
