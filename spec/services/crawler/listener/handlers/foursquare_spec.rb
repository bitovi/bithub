require_relative 'handlers_helper'
require 'events/foursquare/checkin_event'

describe Handlers::Foursquare  do

  ### Helper methods

  def build_foursquare_endpoint
    port   = ENV['CRAWLER_HTTP_PORT'] || 3001
    prefix = ENV['CRAWLER_HTTP_PREFIX'] || '/api/postback/'

    File.join "http://127.0.0.1:#{port}", prefix, ::Handlers::Foursquare.route[1]
  end

  ### Init / cleanup

  before do
    Celluloid.boot
    Celluloid::Actor[:configurator]          = ConfigurationFetcher.new
    Celluloid::Actor[:http_server]           = HttpServer.new
    Celluloid::Actor[:event_publisher]       = EventPublisher.new reject_old: false
    Celluloid::Actor[:subscription_registry] = SubscriptionRegistry.new

    rf = RabbitFactory.new($rabbit_channel)
    @x = rf.x('x.web')
    @q = rf.q('q.web.events').bind(@x, routing_key: 'events')
  end

  after do
    Celluloid.shutdown
  end

  ### Tests

  describe "#handle" do
    it "listens for postbacks, routes and publishes events" do

      brand = { id: 1, name: 'bitovi' }
      embed =  { id: 2, name: 'lonac' }
      service = { id: 3, feed_name: 'foursquare', type_name: 'checkin_event' }

      node = OwnerData.new\
        brand[:id], brand[:name],
        embed[:id], embed[:name],
        service[:id], service[:feed_name], service[:type_name]

      node2 = OwnerData.new\
        brand[:id], brand[:name],
        100, 'do_not_route_here',
        service[:id], service[:feed_name], service[:type_name]

      # register channels
      Celluloid::Actor[:subscription_registry].subscribe 'foursquare', 'venue', '123456789012345678901234', node2
      Celluloid::Actor[:subscription_registry].subscribe 'foursquare', 'venue', '4ef0e7cf7beb5932d5bdeb4e', node

      # simulate postback from foursquare
      post_body = File.new('spec/support/responses/foursquare/checkin_postback').read

      res = HTTParty.post build_foursquare_endpoint, body: post_body

      expect(res.code).to eq 200

      # wait for an event on MQ
      @q.subscribe do |delivery_info, metadata, payload|
        parsed = JSON.parse payload

        expect(parsed['content_digest'].length).to eq(32)
        expect(parsed['meta']['feed_name']).to  eq 'foursquare'
        expect(parsed['meta']['type_name']).to  eq 'checkin_event'
        expect(parsed['meta']['brand_id']).to   eq brand[:id]
        expect(parsed['meta']['brand_name']).to eq brand[:name]
        expect(parsed['meta']['embed_id']).to   eq embed[:id]
        expect(parsed['meta']['embed_name']).to eq embed[:name]
        expect(parsed['meta']['service_id']).to eq service[:id]
      end
    end
  end
end
