class AddInternalTypeToInternals < ActiveRecord::Migration
  def change
    change_table :internals do |t|
      t.string :variant
    end

    Internal.where(:comment => "Completed profile.").update_all(:variant => :completed_profile)
    Internal.where(:comment => "Logged in with Meetup.").update_all(:variant => :linked_meetup)
    Internal.where(:comment => "Logged in with Github.").update_all(:variant => :linked_github)
    Internal.where(:comment => "Logged in with Twitter.").update_all(:variant => :linked_twitter)
  end
end
