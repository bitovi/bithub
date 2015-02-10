module Handlers
  class Instagram

    def initialize(proxy)
      @proxy = proxy
    end

    def handle(req)
      req.method == 'GET' ? handle_subscription(req) : handle_postback(req)
    end

    def self.path
      "/instagram/media/(?<brand_id>\\d+)-(?<brand_name>.*)/(?<embed_id>\\d+)-(?<embed_name>.*)/(?<service_id>\\d+)"
    end

    private

    def handle_subscription(req)
      params =  CGI::parse req.query_string
      [200, params['hub.challenge'].first]
    end

    def handle_postback(req)
      owner_data = build_owner_data_from_url req.url
      payload = JSON.parse req.body.to_s

      payload.each do |notif|
        object      = notif['object']
        object_id   = notif['object_id']
        method_name = "handle_postback_#{object}".to_sym

        if self.respond_to? method_name, true
          results = self.send method_name.to_sym, object_id
          @proxy.publish results, owner_data
        end
      end

      [200, 'OK']
    end

    def build_owner_data_from_url(url)
      captures = Regexp.new(self.class.path).match(url)

      OwnerData.new\
        captures[:brand_id],
        captures[:brand_name],
        captures[:embed_id],
        captures[:embed_name],
        captures[:service_id],
        'instagram',
        'media_event'
    end

    # Subhandlers

    def handle_postback_user(object_id)
      Fetchers::Instagram::UserRecentMedia.fetch object_id, count: 1
    end

    def handle_postback_tag(object_id)
      Fetchers::Instagram::TagRecentMedia.fetch object_id, count: 1
    end

    def handle_postback_location(object_id)
      Fetchers::Instagram::LocationRecentMedia.fetch object_id, count: 1
    end

    def handle_postback_geography(object_id)
      Fetchers::Instagram::LocationRecentMedia.fetch object_id, count: 1
    end

  end
end
