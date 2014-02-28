module Users

  IdentData = Struct.new(:uid, :provider)

  class EntitiesUnlinker

    class UnlinkingJob < Struct.new(:user_id)
      def perform
        EntitiesUnlinker.new(user_id).unlink
      end
    end
    
    def async_unlink
      Delayed::Job.enqueue UnlinkingJob.new(@user_id)
    end

    def initialize(ident_data, user_id)
      @uid, @provider = ident_data.values
      @user_id = user_id
    end

    def unlink
      unlink_entities
      UserActivity.refresh
    end
    
    def unlink_entities
      return if not(user_owns_identity?)

      entities_to_unlink.reduce(true) do |acc, e|
        acc && ownerships_to_destroy(e).reduce(true) do |acc, o|
          acc && o.destroy
        end
      end
    end

    private

    def entities_to_unlink
      Entity.origin_author(@uid).all
    end

    def ownerships_to_destroy(entity)
      entity
      .ownerships
      .where(ownership_type: 'author')
      .where(owner_id: @user_id)
      .all
    end

    def user_owns_identity?
      user = User.find_by_id(@user_id)
      user && user.identities.where(uid: @uid, provider: @provider).present?
    end

  end
end
