module Workers
  class EntitiesTotalVotesUpdater
    include Sidekiq::Worker

    def perform(id)
      entity = Entity.find_by_id(id)
      unless entity.nil?
        entity.update_total_upvotes
      end
    end
  end
end
