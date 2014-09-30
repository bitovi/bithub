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

    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  after do
    Celluloid.shutdown
    @rabbit.close
  end

  ### Tests

  describe "#handle" do
    it "listens for postback notifs, queries API and publishes events" do

      media_raw = load_response 'instagram/media.json'
      notif_raw = load_response 'instagram/notif.json'

      media = JSON.parse media_raw
      notif = JSON.parse notif_raw

      brand_name = 'bitovi'

      # stub request to Instagram API media endpoint
      stub_request(:get, /.*api\.instagram\.com.*/).to_return do |req|
        { body: media_raw }
      end

      # fake postback notification to the crawler
      HTTParty.post build_instagram_endpoint(brand_name), body: notif_raw

      # wait for an event on MQ
      c = @q.subscribe(block: true) do |delivery_info, metadata, payload|
        parsed = JSON.parse payload

        expect(parsed['content_digest'].length).to eq(32)

        expect(parsed['meta']['feed_name']).to eq('instagram')
        expect(parsed['meta']['type_name']).to eq('media_event')
        expect(parsed['meta']['brand_name']).to eq(brand_name)

        expect(parsed['source_data']).to eq(media)

        @rabbit.close
      end

    end
  end

end
