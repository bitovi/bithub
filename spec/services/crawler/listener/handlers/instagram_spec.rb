require_relative 'handlers_helper'
require 'fetchers/instagram/tag_recent_media'

describe Handlers::Instagram  do

  before do
    Celluloid.boot
    Celluloid::Actor[:http_server]           = HttpServer.new
    Celluloid::Actor[:event_publisher]       = EventPublisherMock.new
    Celluloid::Actor[:subscription_registry] = SubscriptionRegistry.new
  end

  after do
    Celluloid.shutdown
  end

  describe '#handle' do
    it 'listens for postback notifs, queries API and publishes events' do

      owner_data = OwnerData.new 1, 'foo', 2, 'bar', 3, 'instagram', 'media_event', {}
      notif_raw  = load_response 'instagram/notif.json'
      endpoint   = build_postback_endpoint 'instagram/media'

      # create subscription for routing
      Celluloid::Actor[:subscription_registry].subscribe 'instagram', 'media', 'nofilter', owner_data

      # fake postback notification to the crawler
      VCR.use_cassette('instagram_media') do
        HTTParty.post endpoint, body: notif_raw
      end

      # examine event publisher mock
      events, od = Celluloid::Actor[:event_publisher].messages.first

      expect(events.length).to eq 1
      expect(od).to eq owner_data
    end
  end
end
