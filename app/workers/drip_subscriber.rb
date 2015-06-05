module Workers
  class DripSubscriber
    include Sidekiq::Worker

    def perform(email)
      DripManager.new.create_or_update_subscriber email
    end

  end
end
