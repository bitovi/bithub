module Users
  class EntitiesUnlinker

    class UnlinkingJob < Struct.new(:user_id)
      def perform
        EntitiesUnlinker.new(user_id).unlink
      end
    end

    def initialize(uid, user_id, provider)
      @uid = uid
      @user_id = user_id
      @provider = provider
    end

    def unlink
      unlink_entities
      UserActivity.refresh
    end
    
    def async_unlink
      Delayed::Job.enqueue UnlinkingJob.new(@user_id)
    end

    def unlink_entities
      Entity.origin_author(@uid).find_each do |e|
        e.ownerships
        .where(ownership_type: 'author')
        .where(owner_id: @user_id)
        .destroy_all
      end
    end

  end
end
