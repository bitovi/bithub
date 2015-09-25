require 'koala'

module Handlers
  module Facebook

    class Notifications

      AVAILABLE_ITEMS = %w(status link checkin photo video)

      def initialize(proxy, opts = {})
        @proxy = proxy
      end

      def handle(req)
        handle_postback req
      end

      def self.route
        ['POST', '/facebook/page/feed']
      end

      private

      def handle_postback(req)
        payload = JSON.parse req.body.to_s
        entries = payload.fetch('entry') { [] }

        entries.each do |entry|
          page_id = entry['id']
          changes = entry.fetch('changes') { [] }

          Celluloid.logger.info "Facebook postback notification for page #{page_id}"
          changes.each {|c| process_change page_id, c}
        end

        # TODO: yield this immediately
        [200, 'OK']
      end

      def process_change(page_id, change)
        object_id = change['value'].andand['post_id']
        return unless object_id

        if subscriptions = @proxy.registry['facebook', 'page', page_id]
          subscriptions.each do |owner_data|
            access_token = owner_data.service.config[:access_token]

            handle_errors(owner_data) do
              result = fetch_object client(access_token), object_id
              @proxy.publish result, owner_data
            end
          end
        end
      end

      def handle_errors(owner_data)
        yield
      rescue => e
        @proxy.publish_error e, owner_data
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
