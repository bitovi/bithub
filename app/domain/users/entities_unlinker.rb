module Users
  class EntitiesUnlinker

    class UnlinkingJob < Struct.new(:uid, :user_id, :provider)
      def perform
        EntitiesUnlinker.new(uid, user_id, provider).unlink
      end
    end

    def initialize(uid, user_id, provider)
      @uid = uid
      @user_id = user_id
      @provider = provider
    end

    def unlink
      unlink_internals
      unlink_entities
      UserActivity.refresh
    end
    
    def async_unlink
      Delayed::Job.enqueue UnlinkingJob.new(@uid, @user_id, @provider)
    end

    def unlink_entities
      Entity.origin_author(@uid).find_each do |e|
        e.ownerships
        .where(ownership_type: 'author')
        .where(owner_id: @user_id)
        .destroy_all
      end
    end

    def unlink_internals
      if (user = User.find_by_id(@user_id))
        user.internals.where(variant: "linked_#{@provider}").destroy_all
      end
    end
  end
end
