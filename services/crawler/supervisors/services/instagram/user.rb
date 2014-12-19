require_relative 'base'

module Supervisors::Services::Instagram
  class User < Base

    def subscribe(params=nil)
      client.create_subscription object: "user", callback_url: callback_url, aspect: "media"
    end

  end
end
