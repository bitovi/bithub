require_relative 'base'

module Supervisors::Services::Instagram
  class Tag < Base

    def subscribe(params)
      tag = params.fetch(:tag)

      client.create_subscription object: "tag", callback_url: callback_url, aspect: "media", object_id: tag
    end

    def preload(params)
      Fetchers::Instagram::TagRecentMedia.fetch params.fetch(:tag), count: 100
    end

  end
end
