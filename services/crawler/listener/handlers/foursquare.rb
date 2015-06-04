module Handlers
  class Foursquare

    def initialize(proxy)
      @proxy = proxy
    end

    def handle(req)
      Celluloid.logger.info "TODO log that something happened?"

      # data is in URL encoded form :/
      payload = CGI.parse req.body.to_s

      secret     = payload['secret'].first
      event_type = determine_type payload
      events     = payload[event_type]

      # pretend dead if someone is cheating
      return [404, 'Not found'] if secret != ENV['FOURSQUARE_PUSH_SECRET']

      events.map {|e| JSON.parse e}.each do |event|
        venue_id = event.fetch('venue').fetch('id')

        if subscriptions = @proxy.registry['foursquare', 'venue', venue_id]
          subscriptions.each do |owner_data|
            @proxy.publish [event], owner_data
          end
        end
      end

      [200, 'OK']
    end

    def self.route
      ['POST', '/foursquare/venues']
    end

    private

    def determine_type(payload)
      (['checkin', 'like', 'tip', 'photo'] & payload.keys).first
    end

  end
end
