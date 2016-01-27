require 'koala'

module Guzzler
  module Listener
    module Handlers

      class FacebookSubscriptions < Handler
        def handle(req)
          err_resp = [403, ':p']
          return err_resp unless req.query_string

          handle_errors do
            params    = CGI::parse req.query_string
            challenge = params['hub.challenge'].first
            token     = params['hub.verify_token'].first

            if token == ENV['FACEBOOK_SUBSCRIPTIONS_VERIFY_TOKEN']
              [200, challenge]
            else
              err_resp
            end
          end
        end
      end

      class FacebookNotifications < Handler
        AVAILABLE_ITEMS = %w(status link checkin photo video)

        def handle(req)
          handle_errors do
            payload = JSON.parse req.body.to_s
            entries = payload.fetch('entry') { [] }
                
            entries.each do |entry|
              page_id = entry['id']
              changes = entry.fetch('changes') { [] }
            
              Guzzler.logger.info "Facebook postback notification for page #{page_id}"

              changes.each do |c|
                object_id = c['value'].andand['post_id']
                next unless object_id

                if subscriptions = @registry.fetch('facebook', 'page', page_id)
                  subscriptions.each do |service|
                    Guzzler.logger.debug "Fetching ..."
                    events = Fetchers::Facebook::GetObject.new(service).fetch(object_id)
                    publish events, service
                  end
                end
              end
            end
          end

          Guzzler.logger.debug "Responding to Facebook"
          [200, 'OK']
        end
      end
    end
  end
end
