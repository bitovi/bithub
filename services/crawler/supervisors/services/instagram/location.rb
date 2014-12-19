require_relative 'base'

module Supervisors::Services::Instagram
  class Location < Base

    def subscribe(params)
      location_id = params.fetch(:location_id)

      client.create_subscription object: "location", callback_url: callback_url, aspect: "media", object_id: location_id
    end

  end
end
