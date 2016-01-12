require 'koala'

module Guzzler
  module Listener
    module Handlers

      class FacebookSubscriptions < Handler
        def handle(req)
          params    = CGI::parse req.query_string
          challenge = params['hub.challenge'].first
          token     = params['hub.verify_token'].first

          if token == ENV['FACEBOOK_SUBSCRIPTIONS_VERIFY_TOKEN']
            [200, challenge]
          else
            [403, ':p']
          end
        end
      end

      class FacebookNotifications < Handler
        AVAILABLE_ITEMS = %w(status link checkin photo video)

        def handle(req)
          super do
            payload = JSON.parse req.body.to_s
            entries = payload.fetch('entry') { [] }

            entries.each do |entry|
              page_id = entry['id']
              updates = entry.fetch('updates') { [] }

              Guzzler.logger.info "Facebook postback notification for page #{page_id}"

              updates.each do |u|
                object_id = update['value'].andand['post_id']
                next unless object_id

                if subscriptions = @registry.fetch('facebook', 'page', page_id)
                  subscriptions.each do |service|
                    Guzzler.logger.debug "Fetching ..."
                    events = fetch_object client(service.config[:access_token]), object_id
                    publish events, service
                  end
                end
              end
            end
          end

          Guzzler.logger.debug "Responding to Facebook"
          # TODO: yield this immediately ?
          [200, 'OK']
        end

        def client(access_token)
          Koala::Facebook::API.new access_token
        end

        def fetch_object(client, object_id)
          Fetchers::Facebook::GetObject.new(client, {object_id: object_id}).fetch
        end

      end

    end
  end
end
