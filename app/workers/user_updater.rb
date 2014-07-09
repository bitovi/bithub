module Workers
  class UserUpdater
    include Sidekiq::Worker

    def perform(id, method)
      user = User.find_by_id(id)
      unless user.nil?
        user.send(method)
      end
    end
  end
end
