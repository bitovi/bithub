require_relative 'base'

module Supervisors::Services::Instagram
  class Location < Base

    def subscribe(params)
      lat    = params.fetch(:lat)
      lng    = params.fetch(:lng)
      radius = params.fetch(:radius)

      client.create_subscription object: "geography", callback_url: callback_url, aspect: "media", lat: lat, lng: lng, radius: radius
    end

  end
end
