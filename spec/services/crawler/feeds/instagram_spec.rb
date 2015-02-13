require_relative 'feeds_helper'

require 'events/instagram/media_event'
require 'fetchers/instagram/tag_recent_media'

describe HttpServer::Handlers::Instagram  do

  ### Helper methods

  def build_instagram_endpoint(owner_data)
    port   = ENV['CRAWLER_HTTP_PORT'] || 3001
    prefix = ENV['CRAWLER_HTTP_PREFIX'] || '/api/postback/'

    brand = owner_data[:brand]
    embed = owner_data[:embed]
    service = owner_data[:service]

    File.join "http://127.0.0.1:#{port}", prefix, 'instagram/media', "#{brand[:id].to_s}-#{brand[:name]}", "#{embed[:id].to_s}-#{embed[:name]}", service[:id].to_s
  end

  def load_response(path)
    File.new("spec/support/responses/#{path}").read.gsub(/\s+/, "")
  end

  ### Init / cleanup

  before do
    Celluloid.boot
    ENV['INSIDE_TEST'] = 'true'
    Celluloid::Actor[:http_server] = HttpServer::Listener.new
    Celluloid::Actor[:event_publisher]   = EventPublisher.new reject_old: false

    rf = RabbitFactory.new($rabbit_channel)
    @x = rf.x('x.web')
    @q = rf.q('q.web.events').bind(@x, routing_key: 'events')
  end

  after do
    Celluloid.shutdown
    ENV['INSIDE_TEST'] = nil
  end

  ### Tests

  describe '#handle' do
    it 'listens for postback notifs, queries API and publishes events' do

      owner_data = {
        brand: { id: 1, name: 'bitovi' },
        embed: { id: 2, name: 'lonac' },
        service: { id: 3 }
      }

      notif_raw = load_response 'instagram/notif.json'
      endpoint = build_instagram_endpoint owner_data

      # fake postback notification to the crawler
      VCR.use_cassette('instagram_media') do
        HTTParty.post endpoint, body: notif_raw
      end

      # wait for an event on MQ
      @q.subscribe do |delivery_info, metadata, payload|
        parsed = JSON.parse payload

        expect(parsed['content_digest'].length).to eq(32)

        expect(parsed['meta']['feed_name']).to  eq 'instagram'
        expect(parsed['meta']['type_name']).to  eq 'media_event'
        expect(parsed['meta']['brand_id']).to   eq owner_data[:brand][:id]
        expect(parsed['meta']['brand_name']).to eq owner_data[:brand][:name]
        expect(parsed['meta']['embed_id']).to   eq owner_data[:embed][:id]
        expect(parsed['meta']['embed_name']).to eq owner_data[:embed][:name]
        expect(parsed['meta']['service_id']).to eq owner_data[:service][:id]
      end
    end
  end
end
