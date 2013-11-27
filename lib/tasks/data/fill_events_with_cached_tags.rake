namespace :data do
  desc "Sets cached_tags attribute for all events"

  task :update_upvotes => :environment do
    Event.reset_column_information

    # next line makes ActsAsTaggableOn see the new column and create cache methods
    ActsAsTaggableOn::Taggable::Cache.included(Event)
    Event.find_each(:batch_size => 1000) do |e|
      e.tag_list # it seems you need to do this first to generate the list
      e.update_attribute('cached_tag_list', e)
    end
  end
end
