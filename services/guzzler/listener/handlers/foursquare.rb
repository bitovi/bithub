module Guzzler
  module Listener
    module Handlers

      class FoursquareData < Handler
        def handle(req)
          super do
            # data is in URL encoded form :/
            payload = CGI.parse req.body.to_s

            secret     = payload['secret'].first
            event_type = determine_type payload
            events     = payload[event_type]

            # pretend dead if someone is cheating
            return [404, 'Not found'] if secret != ENV['FOURSQUARE_PUSH_SECRET']

            events.map { |e| JSON.parse e }.each do |event|
              venue_id = event.fetch('venue').fetch('id')

              if subscriptions = @registry.fetch('foursquare', 'venue', venue_id)
                subscriptions.each do |service|
                  publish [event], service
                end
              end
            end
          end

          [200, 'OK']
        end

        private

        def determine_type(payload)
          (['checkin', 'like', 'tip', 'photo'] & payload.keys).first
        end
      end

    end
  end
end
