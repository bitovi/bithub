module Users
  class Snatcher

    def initialize(current, other)
      @current_user = current
      @other_user = other
    end

    def execute
      snatch_entities
      destroy_other
    end

    def async_execute
      Workers::UserActivitiesSnatcher.perform_async @current_user.id, @other_user.id
    end

    def snatch_entities
      @other_user.ownerships
        .where(:ownership_type => :author)
        .update_all(:owner_id => @current_user.id)
    end

    def destroy_other
      @other_user.destroy
    end
  end
end
