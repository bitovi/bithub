require 'koala'

module Handlers
  class Facebook

    AVAILABLE_ITEMS = %w(status link checkin photo video)

    def initialize(proxy)
      @proxy = proxy
    end

    def handle(req)
      req.method == 'GET' ? handle_subscription(req) : handle_postback(req)
    end

    def self.path
      '/facebook/page/feed'
    end

    private

    def handle_subscription(req)
      params    = CGI::parse req.query_string
      challenge = params['hub.challenge'].first
      token     = params['hub.verify_token'].first

      if token == ENV['FACEBOOK_SUBSCRIPTIONS_VERIFY_TOKEN']
        [200, challenge]
      else
        [403, ':p']
      end
    end

    def handle_postback(req)
      payload = JSON.parse req.body.to_s
      entries = payload.fetch('entry') { [] }

      entries.each do |entry|
        page_id = entry['id']
        changes = entry.fetch('changes') { [] }

        @proxy.logger.info "Facbook postback notification for page #{page_id}"

        changes.each {|c| process_change page_id, c}
      end

      # TODO: yield this immediately
      [200, 'OK']
    end

    def process_change(page_id, change)
      object_id = change['value'].andand['post_id']
      return unless object_id

      matched_services = Celluloid::Actor[:configurator].traverse 'facebook', 'page', :id, page_id

      matched_services.each do |sc|
        client     = Koala::Facebook::API.new sc[:service][:config][:access_token]
        owner_data = OwnerData.new sc[:brand_id], sc[:brand_name], sc[:embed_id], sc[:embed_name], sc[:service][:id], 'facebook', 'page'

        # I'm crying .... ;-(

        result = fetch_object client, object_id
        @proxy.publish result, owner_data
      end
    end

    def fetch_object(client, object_id)
      Fetchers::Facebook::GetObject.new(client).fetch object_id
    end

  end
end
