require_relative 'feeds_helper'

require 'events/foursquare/checkin_event'

describe HttpServer::Handlers::Foursquare  do

  ### Helper methods

  def build_foursquare_endpoint
    port   = ENV['CRAWLER_HTTP_PORT'] || 3001
    prefix = ENV['CRAWLER_HTTP_PREFIX'] || '/api/postback/'

    File.join "http://127.0.0.1:#{port}", prefix, HttpServer::Handlers::Foursquare.path
  end

  ### Init / cleanup

  before do
    Celluloid.boot

    Celluloid::Actor[:publisher]    = Publisher.new reject_old: false
    Celluloid::Actor[:configurator] = Configurator.new
    Celluloid::Actor[:http_server]  = HttpServer.new

    rabbitmq_uri = ENV['RABBITMQ_URI']

    @rabbit = Bunny.new(rabbitmq_uri)
    @rabbit.start
    @chan = @rabbit.create_channel

    @x = @chan.direct("x.events")
    @q = @chan.queue("q.events").bind(@x)
  end

  after do
    Celluloid.shutdown
    @rabbit.close
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
      Celluloid::Actor[:foursquare_handler].handler.subscribe '123456789012345678901234', node2
      Celluloid::Actor[:foursquare_handler].handler.subscribe '4ef0e7cf7beb5932d5bdeb4e', node

      # simulate postback from foursquare
      post_body = File.new('spec/support/responses/foursquare/checkin_postback').read
      res = HTTParty.post build_foursquare_endpoint, body: post_body

      expect(res.code).to eq 200

      # wait for an event on MQ
      c = @q.subscribe(block: true) do |delivery_info, metadata, payload|
        parsed = JSON.parse payload

        expect(parsed['content_digest'].length).to eq(32)

        expect(parsed['meta']['feed_name']).to  eq 'foursquare'
        expect(parsed['meta']['type_name']).to  eq 'checkin_event'
        expect(parsed['meta']['brand_id']).to   eq brand[:id]
        expect(parsed['meta']['brand_name']).to eq brand[:name]
        expect(parsed['meta']['embed_id']).to   eq embed[:id]
        expect(parsed['meta']['embed_name']).to eq embed[:name]
        expect(parsed['meta']['service_id']).to eq service[:id]

        @rabbit.close
      end

    end
  end

end
