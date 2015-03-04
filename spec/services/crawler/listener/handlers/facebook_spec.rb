require_relative 'handlers_helper'

require 'fetchers/facebook/get_object'

describe Handlers::Facebook  do

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

      owner_data = OwnerData.new 1, 'foo', 2, 'bar', 3, 'facebook', 'page'
      notif_raw  = load_response 'facebook/notif.json'
      endpoint   = build_postback_endpoint ::Handlers::Facebook::Subscriptions.route[1]

      subscription = {
        owner_data: owner_data,
        access_token: 'do_not_change'
      }

      # create subscription for routing
      Celluloid::Actor[:subscription_registry].subscribe 'facebook', 'page', '778255945594351', subscription

      # fake postback notification to the crawler
      VCR.use_cassette('facebook_object') do
        HTTParty.post endpoint, body: notif_raw
      end

      # examine event publisher mock
      events, od = Celluloid::Actor[:event_publisher].messages.first

      expect(events.length).to eq 1
      expect(od).to eq owner_data

    end
  end

end
