module Workers
  class UserActivitiesSnatcher
    include Sidekiq::Worker

    def perform(current_user_id, other_user_id)
      current_user = User.find_by_id current_user_id
      other_user = User.find_by_id other_user_id
      if current_user && other_user
        ActivitiesAndEntitiesSnatcher.new(current_user, other_user).execute
        DuplicateInternalsCleaner.new(current_user).execute
        current_user.update_total_score
      end
    end
  end
end
