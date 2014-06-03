class CreateFunnelConstraints < ActiveRecord::Migration
  def change
    create_table :funnel_constraints do |t|
      t.string       :feed_name
      t.string       :type_name
      t.string_array :tags
    end
  end
end
