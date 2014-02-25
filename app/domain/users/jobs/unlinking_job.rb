module Users
  module Jobs

    class UnlinkingJob < Struct.new(:uid, :user_id, :provider)
      def perform
        EntitiesUnlinker.new(uid, user_id, provider).unlink
      end
    end

  end
end
