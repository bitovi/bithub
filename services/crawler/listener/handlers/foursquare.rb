module Handlers
  class Foursquare

    def initialize(proxy)
      @proxy = proxy
      boot
    end

    def boot
      traverse_config_tree
    end

    def handle(req)
      # data is in URL encoded form :/
      payload = CGI.parse req.body.to_s

      secret     = payload['secret'].first
      event_type = determine_type payload
      events     = payload[event_type]

      # pretend dead if someone is cheating
      return [404, 'Not found'] if secret != ENV['FOURSQUARE_PUSH_SECRET']

      events.map {|e| JSON.parse e}.each do |event|
        id = event.fetch('venue').fetch('id')

        if owners = subscriptions[id]
          owners.each {|o| @proxy.publish [event], o}
        end
      end

      [200, 'OK']
    end

    def self.path
      '/foursquare/venues'
    end

    def subscribe(id, owner_data)
      subscriptions[id] << owner_data
    end

    private

    def subscriptions
      @subscriptions ||= Hash.new {|h,k| h[k] = []}
    end

    def determine_type(payload)
      (['checkin', 'like', 'tip', 'photo'] & payload.keys).first
    end

    def traverse_config_tree
      config = @proxy.config

      config.fetch(:brands).each do |b|
        b.fetch(:embeds).each do |e|
          e.fetch(:services).each do |s|
            if s[:feed_name] == 'foursquare' && s[:type_name] == 'venue'
              venue_id = s[:config][:id]
              owner_data = OwnerData.new b[:id], b[:name], e[:id], e[:name], s[:id], 'foursquare', "#{determine_type(payload)}_event"

              subscribe venue_id, owner_data
            end
          end
        end
      end
    end

  end
end
