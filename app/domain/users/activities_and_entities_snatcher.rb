module Users
  class ActivitiesAndEntitiesSnatcher

    class SnatchingJob < Struct.new(:current_user_id, :other_user_id)
      def perform
        current_user = User.find_by_id current_user_id
        other_user = User.find_by_id other_user_id
        if current_user && other_user
          ActivitiesAndEntitiesSnatcher.new(current_user, other_user).execute
          DuplicateInternalsCleaner.new(current_user).execute
          current_user.update_total_score
        end
      end
    end

    def initialize(current, other)
      @current_user = current
      @other_user = other
    end

    def execute
      snatch_entities
      snatch_actions
      snatch_internals
      destroy_other
      update_total_score
    end

    def async_execute
      Delayed::Job.enqueue SnatchingJob.new(@current_user.id, @other_user.id)
    end

    def snatch_entities
      @other_user.ownerships
        .where(:ownership_type => :author)
        .update_all(:owner_id => @current_user)
    end

    def snatch_actions
      @other_user.awards_as_actor.update_all(:actor_id => @current_user)
      @other_user.anteups_as_actor.update_all(:actor_id => @current_user)
      @other_user.upvotes_as_actor.update_all(:actor_id => @current_user)
      @other_user.internals_as_actor.update_all(:actor_id => @current_user)
    end

    def snatch_internals
      @other_user.internals.update_all(:receiver_id => @current_user)
    end

    def destroy_other
      @other_user.destroy
    end

    def update_total_score
      @current_user.update_total_score
    end

  end
end
