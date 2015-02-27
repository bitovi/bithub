require_relative 'base'

module Supervisors::Services::Instagram
  class User < Base

    def subscribe(params=nil)
      client.create_subscription object: "user", callback_url: callback_url, aspect: "media"
    end

    def preloaded_items(params)
      Fetchers::Instagram::UserRecentMedia.fetch params.fetch(:id), count: 100
    end

  end
end
