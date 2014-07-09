module Workers
  class EntitiesFakeDigestsCreator
    include Sidekiq::Worker

    def perform(ident_uid)
      if (ident = Identity.find_by_uid(ident_uid))
        FakeDigestsCreator.new(ident).execute
      end
    end
  end
end
