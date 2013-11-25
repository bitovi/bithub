class AddCacheForTags < ActiveRecord::Migration
  def up
    add_column :events, :cached_tag_list, :string
    Event.reset_column_information
    # next line makes ActsAsTaggableOn see the new column and create cache methods
    ActsAsTaggableOn::Taggable::Cache.included(Event)
    Event.find_each(:batch_size => 1000) do |e|
      e.tag_list # it seems you need to do this first to generate the list
      e.update_attribute('cached_tag_list', e)
    end
  end

  def down
  end
end