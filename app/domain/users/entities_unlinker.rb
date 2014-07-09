module Users

  IdentData = Struct.new(:uid, :provider)

  class EntitiesUnlinker

    def async_unlink
      Workers::EntitiesUnlinker.perform_async IdentData.new(@uid, @provider), @user_id
    end

    def initialize(ident_data, user_id)
      @uid, @provider = ident_data.values
      @user_id = user_id
    end

    def unlink
      unlink_authored_entities
      unlink_hosted_entities
      UserActivity.refresh
    end

    def unlink_authored_entities
      return if not(user_owns_identity?)

      authored_entities_to_unlink.reduce(true) do |acc, e|
        acc && ownerships_to_destroy(e).reduce(true) do |acc, o|
          acc && o.destroy
        end
      end
    end

    def unlink_hosted_entities
      return if not(user_owns_identity?)

      hosted_entities_to_unlink.reduce(true) do |acc, e|
        acc && ownerships_to_destroy(e, :host).reduce(true) do |acc, o|
          acc && o.destroy
        end
      end
    end

    private

    def authored_entities_to_unlink
      Entity.origin_author(@uid).all
    end

    def hosted_entities_to_unlink
      Entity.origin_host(@uid).all
    end

    def ownerships_to_destroy(entity, type=:author)
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
