require_relative 'base'

module Supervisors::Services::Instagram
  class Geography < Base

    def subscribe(params)
      lat    = params.fetch(:lat)
      lng    = params.fetch(:lng)
      radius = params.fetch(:radius)

      client.create_subscription object: "geography", callback_url: callback_url, aspect: "media", lat: lat, lng: lng, radius: radius
    end

    # Implement later b/c --> http://instagram.com/developer/endpoints/geographies/
    # def preload(params)
    #   Fetchers::Instagram::GeographyRecentMedia.fetch params.fetch(:id), count: 100
    # end

  end
end
