module Users
  class EntitiesUnlinker

    def initialize(uid, user_id, provider)
      @uid = uid
      @user_id = user_id
      @provider = provider
    end

    def unlink
      unlink_authored_entities
      unlink_hosted_entities
      UserActivity.refresh
    end
    
    def async_unlink
      Delayed::Job.enqueue Jobs::UnlinkingJob.new(@uid, @user_id, @provider)
    end

    def unlink_authored_entities
      Entity.origin_author(@uid).find_each do |e|
        e.ownerships.where(ownership_type: 'author')
        .where(owner_id: @user_id)
        .destroy_all
      end
    end
    
    def unlink_hosted_entities
      Entity.origin_host(@uid).find_each do |e|
        e.ownerships.where(ownership_type: 'host')
        .where(owner_id: @user_id)
        .destroy_all
      end
    end

  end
end
