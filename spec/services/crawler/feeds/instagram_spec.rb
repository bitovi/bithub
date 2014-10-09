require_relative 'feeds_helper'

require 'events/instagram/media_event'
require 'fetchers/instagram/media'

describe HttpServer::Handlers::Instagram  do

  ### Helper methods

  def build_instagram_endpoint(brand)
    port   = ENV['CRAWLER_HTTP_PORT'] || 3001
    prefix = ENV['CRAWLER_HTTP_PREFIX'] || '/api/postback/'

    File.join "http://127.0.0.1:#{port}", prefix, 'instagram/media', brand
  end

  def load_response(path)
    File.new("spec/support/responses/#{path}").read.gsub(/\s+/, "")
  end

  ### Init / cleanup

  before do
    Celluloid.boot

    Celluloid::Actor[:http_server] = HttpServer::Listener.new
    Celluloid::Actor[:publisher]   = Publisher.new reject_old: false

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
    it "listens for postback notifs, queries API and publishes events" do

      notif_raw = load_response 'instagram/notif.json'
      brand_name = 'bitovi'

      # fake postback notification to the crawler
      VCR.use_cassette('instagram_media') do
        HTTParty.post build_instagram_endpoint(brand_name), body: notif_raw
      end

      # wait for an event on MQ
      c = @q.subscribe(block: true) do |delivery_info, metadata, payload|
        parsed = JSON.parse payload

        expect(parsed['content_digest'].length).to eq(32)

        expect(parsed['meta']['feed_name']).to eq('instagram')
        expect(parsed['meta']['type_name']).to eq('media_event')
        expect(parsed['meta']['brand_name']).to eq(brand_name)

        @rabbit.close
      end

    end
  end

end
