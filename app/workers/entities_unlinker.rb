module Workers
  class EntitiesUnlinker
    include Sidekiq::Worker

    def perform(uid, user_id, provider)
      EntitiesUnlinker.new(uid, user_id, provider).unlink
    end
  end
end
