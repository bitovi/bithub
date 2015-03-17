require_relative 'handlers_helper'

describe Handlers::Foursquare  do

  before do
    Celluloid.boot
    Celluloid::Actor[:http_server]           = HttpServer.new
    Celluloid::Actor[:event_publisher]       = EventPublisherMock.new
    Celluloid::Actor[:subscription_registry] = SubscriptionRegistry.new
  end

  after do
    Celluloid.shutdown
  end

  describe "#handle" do
    it "listens for postbacks and publishes events" do

      owner_data = OwnerData.new 1, 'foo', 2, 'bar', 3, 'foursquare', 'checkin_event', {}
      post_body  = load_response 'foursquare/checkin_postback'
      endpoint   = build_postback_endpoint ::Handlers::Foursquare.route[1]

      # subscribe for routing
      Celluloid::Actor[:subscription_registry].subscribe 'foursquare', 'venue', '4ef0e7cf7beb5932d5bdeb4e', owner_data

      # simulate postback from foursquare
      res = HTTParty.post endpoint, body: post_body
      expect(res.code).to eq 200

      # examine event publisher mock
      events, od = Celluloid::Actor[:event_publisher].messages.first

      expect(events.length).to eq 1
      expect(od).to eq owner_data
    end
  end
end
