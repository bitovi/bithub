class CreateFunnels < ActiveRecord::Migration
  def change
    create_table :funnels do |t|
      t.string       :feed_name
      t.string       :type_name
      t.string_array :tags
    end
  end
end
